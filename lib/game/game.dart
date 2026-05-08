import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show EdgeInsets, VoidCallback;

import 'components/player.dart';
import 'components/projectile.dart';
import 'game_constants.dart';
import 'skills/skill_offer.dart';
import 'systems/spawn_system.dart';
import 'systems/xp_system.dart';
import 'world/game_world.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  final VoidCallback onQuit;
  late Player player;
  late final GameWorld _world;
  late final CameraComponent _cam;
  late final XpSystem _xpSystem;

  final List<PositionComponent> _enemies = [];
  int killCount = 0;

  late final ValueNotifier<int> playerHpNotifier;
  int get playerMaxHp => Player.maxHp;
  ValueNotifier<(int, int, int)> get xpNotifier => _xpSystem.notifier;

  // ── Skill state ──────────────────────────────────────────────
  int _projectileSpeedLevel = 0;
  int _pendingLevelUps = 0;

  List<SkillOffer> get currentLevelUpOffers => List.generate(
        3,
        (_) => SkillOffer(
          title: 'Project Speed',
          description: 'Aumenta a velocidade de ataque',
          nextLevel: _projectileSpeedLevel + 1,
          onSelect: _applyProjectileSpeed,
        ),
      );

  MyGame({required this.onQuit});

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    playerHpNotifier = ValueNotifier(Player.maxHp);
    _xpSystem = XpSystem(onLevelUp: _onLevelUp);

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
      targets: _enemies,
      onFire: (pos, dir) => _world.add(Projectile(position: pos, direction: dir)),
      onHpChanged: (hp) => playerHpNotifier.value = hp,
      onDeath: _onPlayerDeath,
    )..position = Vector2(GameConstants.mapWidth / 2, GameConstants.mapHeight / 2);
    _world.add(player);
    _cam.follow(player);

    _world.add(SpawnSystem(
      playerRef: player,
      enemies: _enemies,
      onKill: () => killCount++,
      onXpCollect: _xpSystem.collect,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    _cam.viewfinder.position = Vector2(
      _cam.viewfinder.position.x.clamp(halfW, GameConstants.mapWidth - halfW),
      _cam.viewfinder.position.y.clamp(halfH, GameConstants.mapHeight - halfH),
    );
  }

  // ── Skill application ────────────────────────────────────────

  void _applyProjectileSpeed() {
    _projectileSpeedLevel++;
    // Reduz o cooldown em 0.05s por nível (mínimo 0.05s)
    player.cooldownDuration = (0.4 - _projectileSpeedLevel * 0.05).clamp(0.05, 0.4);
    // A cada 3 níveis, adiciona um projétil paralelo
    player.projectileCount = 1 + _projectileSpeedLevel ~/ 3;
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
      // Mais um level pendente: mostra o overlay de novo imediatamente
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

  void quitGame() => onQuit();
}
