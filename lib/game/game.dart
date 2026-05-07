import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show Color, Colors, EdgeInsets, VoidCallback;

import 'enemy.dart';
import 'game_constants.dart';
import 'player.dart';
import 'projectile.dart';
import 'puddle.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final VoidCallback onQuit;
  late Player player;
  late final World _world;
  late final CameraComponent _cam;
  final List<Enemy> _enemies = [];
  final _random = Random();

  int killCount = 0;
  late final ValueNotifier<int> playerHpNotifier;
  int get playerMaxHp => Player.maxHp;

  static const double _spawnInterval = 3.0;
  static const int _spawnCount = 3;
  static const double _spawnMinDistance = 300.0;

  static const _spawnColors = <Color>[
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.cyan,
    Colors.purple,
    Colors.pink,
    Colors.lightBlue,
    Colors.lightGreen,
  ];

  double _spawnTimer = 0;

  MyGame({required this.onQuit});

  @override
  Future<void> onLoad() async {
    playerHpNotifier = ValueNotifier(Player.maxHp);

    _world = World();
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

    _world.add(_CheckerboardBackground());

    player = Player(
      joystick,
      enemies: _enemies,
      onFire: (pos, dir) => _world.add(
        Projectile(position: pos, direction: dir),
      ),
      onHpChanged: (hp) => playerHpNotifier.value = hp,
      onDeath: _onPlayerDeath,
    )..position = Vector2(
        GameConstants.mapWidth / 2,
        GameConstants.mapHeight / 2,
      );
    _world.add(player);
    _cam.follow(player);

    for (int i = 0; i < 3; i++) {
      _spawnRandomEnemy();
    }
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

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer -= _spawnInterval;
      for (int i = 0; i < _spawnCount; i++) {
        _spawnRandomEnemy();
      }
    }
  }

  void _onPlayerDeath() {
    pauseEngine();
    overlays.remove('hud');
    overlays.add('gameover');
  }

  void _spawnEnemy({
    required double speed,
    required Color color,
    required EnemyShape shape,
    required int initialHp,
    required Vector2 position,
  }) {
    late final Enemy e;
    e = Enemy(
      player,
      speed: speed,
      color: color,
      shape: shape,
      initialHp: initialHp,
      onDeath: (pos, c) {
        _enemies.remove(e);
        killCount++;
        _world.add(Puddle(position: pos, color: c));
      },
    )..position = position;
    _enemies.add(e);
    _world.add(e);
  }

  void _spawnRandomEnemy() {
    final color = _spawnColors[_random.nextInt(_spawnColors.length)];
    final shape = EnemyShape.values[_random.nextInt(EnemyShape.values.length)];
    final initialHp = 10 + _random.nextInt(21);
    final speed = 50.0 + _random.nextDouble() * 100;

    _spawnEnemy(
      speed: speed,
      color: color,
      shape: shape,
      initialHp: initialHp,
      position: _randomSpawnPosition(),
    );
  }

  Vector2 _randomSpawnPosition() {
    Vector2 pos;
    var tries = 0;
    do {
      pos = Vector2(
        _random.nextDouble() * GameConstants.mapWidth,
        _random.nextDouble() * GameConstants.mapHeight,
      );
      tries++;
    } while (
        (pos - player.position).length < _spawnMinDistance && tries < 20);
    return pos;
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

class _CheckerboardBackground extends PositionComponent {
  static const _tile = 32.0;

  final _paintA = Paint()..color = const Color(0xFF888888);
  final _paintB = Paint()..color = const Color(0xFF555555);

  _CheckerboardBackground()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.mapWidth, GameConstants.mapHeight),
        );

  @override
  void render(Canvas canvas) {
    final cols = (GameConstants.mapWidth / _tile).ceil();
    final rows = (GameConstants.mapHeight / _tile).ceil();
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        canvas.drawRect(
          Rect.fromLTWH(x * _tile, y * _tile, _tile, _tile),
          (x + y) % 2 == 0 ? _paintA : _paintB,
        );
      }
    }
  }
}
