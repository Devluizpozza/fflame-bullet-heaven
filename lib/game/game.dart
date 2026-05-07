import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Colors, EdgeInsets, VoidCallback;

import 'enemy.dart';
import 'game_constants.dart';
import 'player.dart';
import 'projectile.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final VoidCallback onQuit;
  late Player player;
  late final World _world;
  late final CameraComponent _cam;
  final List<Enemy> _enemies = [];

  MyGame({required this.onQuit});

  @override
  Future<void> onLoad() async {
    _world = World();
    _cam = CameraComponent(world: _world);
    addAll([_world, _cam]);

    // Joystick fixo na tela (HUD — não se move com a câmera)
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

    // Fundo xadrez cobre o mapa inteiro (componente único — eficiente)
    _world.add(_CheckerboardBackground());

    // Player no centro do mapa
    // _enemies é passado por referência — estará populado quando o player
    // começar a chamar update(), mesmo sendo criado antes dos inimigos.
    player = Player(
      joystick,
      enemies: _enemies,
      onFire: (pos, dir) => _world.add(
        Projectile(position: pos, direction: dir),
      ),
    )..position = Vector2(
        GameConstants.mapWidth / 2,
        GameConstants.mapHeight / 2,
      );
    _world.add(player);

    // Câmera segue o player
    _cam.follow(player);

    _spawnEnemy(speed: 70, color: Colors.red,
        offset: Vector2(-400, -350)); // acima-esquerda
    _spawnEnemy(speed: 85, color: Colors.green,
        offset: Vector2(350, -300));  // acima-direita
    _spawnEnemy(speed: 55, color: Colors.yellow,
        offset: Vector2(0, 400));     // abaixo
  }

  void _spawnEnemy({
    required double speed,
    required Color color,
    required Vector2 offset,
  }) {
    final e = Enemy(player, speed: speed, color: color)
      ..position = Vector2(
        GameConstants.mapWidth / 2 + offset.x,
        GameConstants.mapHeight / 2 + offset.y,
      );
    _enemies.add(e);
    _world.add(e);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Impede a câmera de mostrar fora dos limites do mapa
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    _cam.viewfinder.position = Vector2(
      _cam.viewfinder.position.x.clamp(halfW, GameConstants.mapWidth - halfW),
      _cam.viewfinder.position.y.clamp(halfH, GameConstants.mapHeight - halfH),
    );
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

// Renderiza o xadrez inteiro em um único componente — muito mais eficiente
// do que adicionar milhares de RectangleComponents individuais.
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
