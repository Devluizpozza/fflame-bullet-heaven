import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show EdgeInsets, VoidCallback;

import 'components/enemy.dart';
import 'components/interfaces.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'events/game_event_bus.dart';
import 'events/game_events.dart';
import 'game_constants.dart';
import 'player_stats.dart';
import 'skills/explosion_on_kill_skill.dart';
import 'skills/skill.dart';
import 'skills/skill_offer.dart';
import 'skills/skill_upgrade.dart';
import 'skills/projectile_speed_skill.dart';
import 'skills/storm_rage_skill.dart';
import 'systems/spawn_system.dart';
import 'systems/xp_system.dart';
import 'world/game_world.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  final VoidCallback onQuit;
  final PlayerStats playerStats = PlayerStats();
  final GameEventBus eventBus = GameEventBus();
  final _random = Random();
  late Player player;
  late final GameWorld _world;
  late final CameraComponent _cam;
  late final XpSystem _xpSystem;

  final List<PositionComponent> _enemies = [];
  int killCount = 0;
  int _lastMinute = 0;

  late final ValueNotifier<int> playerHpNotifier;
  late final ValueNotifier<int> timerNotifier;
  double _elapsedTime = 0;

  int get playerMaxHp => playerStats.maxHp.toInt();
  ValueNotifier<(int, int, int)> get xpNotifier => _xpSystem.notifier;

  // ── Skill state ──────────────────────────────────────────────
  int _pendingLevelUps = 0;

  late final List<Skill> _availableSkills;

  late final ValueNotifier<List<(String, int)>> collectedSkillsNotifier;

  /// Gera 3 ofertas a partir de um pool plano de todos os (skill, upgrade)
  /// possíveis. Cada caminho de upgrade é uma entrada independente no pool,
  /// então upgrades distintos da mesma skill competem entre si pelo sorteio.
  List<SkillOffer> get currentLevelUpOffers {
    final pool = <(Skill, SkillUpgrade)>[
      for (final skill in _availableSkills)
        for (final upgrade in skill.upgrades) (skill, upgrade),
    ]..shuffle(_random);

    // Garante 3 ofertas mesmo com pool pequeno (repete se necessário)
    final result = <SkillOffer>[];
    while (result.length < 3) {
      final idx = result.length % pool.length;
      final (skill, upgrade) = pool[idx];
      result.add(_makeOffer(skill, upgrade));
    }
    return result;
  }

  SkillOffer _makeOffer(Skill skill, SkillUpgrade upgrade) => SkillOffer(
        title: upgrade.name,
        description: upgrade.description,
        nextLevel: skill.level + 1,
        onSelect: () => _applySkill(skill, upgrade),
      );

  MyGame({required this.onQuit});

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    playerHpNotifier = ValueNotifier(playerStats.maxHp.toInt());
    timerNotifier = ValueNotifier(0);
    collectedSkillsNotifier = ValueNotifier([]);

    _availableSkills = [
      ProjectileSpeedSkill(),
      ExplosionOnKillSkill(onExplode: _handleExplosion),
      StormRageSkill(onStrike: _handleLightningStrike),
    ];

    for (final skill in _availableSkills) {
      skill.register(eventBus);
    }

    eventBus.on<EnemyKilledEvent>((_) => killCount++);

    _xpSystem = XpSystem(
      onLevelUp: () {
        eventBus.emit(LevelUpEvent(_xpSystem.level));
        _onLevelUp();
      },
    );

    _world = GameWorld();
    _cam = CameraComponent(world: _world);
    addAll([_world, _cam]);

    final joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 24,
        paint: Paint()..color = const Color(0xCCFFFFFF),
      ),
      background: CircleComponent(
        radius: 56,
        paint: Paint()..color = const Color(0x66FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 48, bottom: 48),
    );
    _cam.viewport.add(joystick);

    _world.add(TiledBackground());

    player = Player(
      joystick,
      stats: playerStats,
      targets: _enemies,
      onFire: (pos, dir) => _world.add(Projectile(
        position: pos,
        direction: dir,
        speed: playerStats.projectileSpeed,
        damage: playerStats.damage.toInt(),
      )),
      onHpChanged: (hp) => playerHpNotifier.value = hp,
      onDamaged: (amount, currentHp) =>
          eventBus.emit(PlayerDamagedEvent(amount: amount, currentHp: currentHp)),
      onDeath: _onPlayerDeath,
    )..position = Vector2(GameConstants.mapWidth / 2, GameConstants.mapHeight / 2);
    _world.add(player);
    _cam.follow(player);

    _world.add(SpawnSystem(
      playerRef: player,
      enemies: _enemies,
      eventBus: eventBus,
      onXpCollect: _xpSystem.collect,
      onHealPlayer: player.heal,
      onGrantFullLevel: _grantFullLevel,
    ));

    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    final secs = _elapsedTime.floor();
    if (secs != timerNotifier.value) timerNotifier.value = secs;

    final minute = secs ~/ 60;
    if (minute > _lastMinute) {
      _lastMinute = minute;
      eventBus.emit(MinutePassedEvent(minute));
    }

    final halfW = size.x / 2;
    final halfH = size.y / 2;
    _cam.viewfinder.position = Vector2(
      _cam.viewfinder.position.x.clamp(halfW, GameConstants.mapWidth - halfW),
      _cam.viewfinder.position.y.clamp(halfH, GameConstants.mapHeight - halfH),
    );
  }

  // ── Explosion AoE ────────────────────────────────────────────

  void _handleExplosion(Vector2 position, double radius, int damage) {
    for (final enemy in List.of(_enemies)) {
      if ((enemy.position - position).length <= radius) {
        if (enemy is Damageable) enemy.takeDamage(damage);
      }
    }
  }

  // ── Lightning Strike ─────────────────────────────────────────

  void _handleLightningStrike(Vector2 origin, int count) {
    if (_enemies.isEmpty) return;
    final pool = List.of(_enemies)..shuffle(_random);
    final targets = pool.take(count);
    for (final t in targets) {
      if (t is Enemy) {
        t.flashBlue();
        t.takeDamage(20);
      }
    }
  }

  // ── Boss reward ──────────────────────────────────────────────

  void _grantFullLevel() {
    final needed = _xpSystem.xpRequired - _xpSystem.currentXp;
    _xpSystem.collect(needed > 0 ? needed : 1);
  }

  // ── Skill application ────────────────────────────────────────

  void _applySkill(Skill skill, SkillUpgrade upgrade) {
    upgrade.apply(player);

    final skills = [...collectedSkillsNotifier.value];
    final idx = skills.indexWhere((s) => s.$1 == skill.name);
    if (idx >= 0) {
      skills[idx] = (skill.name, skill.level);
    } else {
      skills.add((skill.name, skill.level));
    }
    collectedSkillsNotifier.value = skills;

    _onSkillSelected();
  }

  // ── Level-up flow ────────────────────────────────────────────

  void _onLevelUp() {
    _pendingLevelUps++;
    if (_pendingLevelUps == 1) _showLevelUpOverlay();
  }

  void _showLevelUpOverlay() {
    pauseEngine();
    overlays.remove('hud');
    overlays.add('levelup');
  }

  void _onSkillSelected() {
    _pendingLevelUps--;
    overlays.remove('levelup');
    if (_pendingLevelUps > 0) {
      _showLevelUpOverlay();
    } else {
      overlays.add('hud');
      resumeEngine();
    }
  }

  // ── Game flow ────────────────────────────────────────────────

  void _onPlayerDeath() {
    pauseEngine();
    overlays.remove('hud');
    overlays.add('gameover');
  }

  void pauseGame() {
    pauseEngine();
    overlays.remove('hud');
    overlays.add('pause');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('pause');
    overlays.add('hud');
  }

  void quitGame() {
    pauseEngine();
    onQuit();
  }
}
