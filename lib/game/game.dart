import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Colors, EdgeInsets, VoidCallback;

import 'enemy.dart';
import 'game_constants.dart';
import 'player.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  final VoidCallback onQuit;
  late Player player;
  late final World _world;
  late final CameraComponent _cam;

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
    player = Player(joystick)
      ..position = Vector2(
        GameConstants.mapWidth / 2,
        GameConstants.mapHeight / 2,
      );
    _world.add(player);

    // Câmera segue o player
    _cam.follow(player);

    // Vermelho — acima e à esquerda do player, velocidade média
    _world.add(
      Enemy(player, speed: 70, color: Colors.red)
        ..position = Vector2(
          GameConstants.mapWidth / 2 - 400,
          GameConstants.mapHeight / 2 - 350,
        ),
    );

    // Verde — acima e à direita do player, mais rápido
    _world.add(
      Enemy(player, speed: 85, color: Colors.green)
        ..position = Vector2(
          GameConstants.mapWidth / 2 + 350,
          GameConstants.mapHeight / 2 - 300,
        ),
    );

    // Amarelo — abaixo do player, mais lento
    _world.add(
      Enemy(player, speed: 55, color: Colors.yellow)
        ..position = Vector2(
          GameConstants.mapWidth / 2,
          GameConstants.mapHeight / 2 + 400,
        ),
    );
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
