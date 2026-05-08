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

  MyGame({required this.onQuit});

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    playerHpNotifier = ValueNotifier(Player.maxHp);
    _xpSystem = XpSystem();

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
