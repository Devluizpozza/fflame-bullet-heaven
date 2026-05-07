import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show Color, Colors, EdgeInsets, VoidCallback;
import 'package:flutter/services.dart' show rootBundle;

import 'enemy.dart';
import 'game_constants.dart';
import 'player.dart';
import 'projectile.dart';
import 'puddle.dart';
import 'xp_orb.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  final VoidCallback onQuit;
  late Player player;
  late final _GameWorld _world;
  late final CameraComponent _cam;
  final List<Enemy> _enemies = [];
  final _random = Random();

  int killCount = 0;
  late final ValueNotifier<int> playerHpNotifier;
  int get playerMaxHp => Player.maxHp;

  int level = 1;
  int currentXp = 0;
  late final ValueNotifier<(int, int, int)> xpNotifier;
  int get _xpRequired => 10 << (level - 1);

  void collectXp(int amount) {
    currentXp += amount;
    while (currentXp >= _xpRequired) {
      currentXp -= _xpRequired;
      level++;
    }
    xpNotifier.value = (currentXp, _xpRequired, level);
  }

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
    xpNotifier = ValueNotifier((0, _xpRequired, level));

    _world = _GameWorld();
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

    _world.add(_TiledBackground());

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
        if (_random.nextInt(10) < 7) {
          _world.add(XpOrb(
            position: pos,
            player: player,
            xpValue: e.maxHp,
            color: c,
            onCollect: collectXp,
          ));
        }
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

// HasCollisionDetection no World garante que a detecção opere no mesmo
// espaço de coordenadas dos componentes — necessário no sistema CameraComponent.
class _GameWorld extends World with HasCollisionDetection {}

// Usa ImageShader com TileMode.repeated — uma única draw call via GPU.
class _TiledBackground extends PositionComponent {
  late Paint _paint;

  _TiledBackground()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.mapWidth, GameConstants.mapHeight),
        );

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load('lib/assets/tiles/dirty_floor.png');
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final tile = frame.image;

    _paint = Paint()
      ..shader = ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList([
          1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        ]),
      );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      _paint,
    );
  }
}
