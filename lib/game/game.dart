import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' show Colors, EdgeInsets, VoidCallback;

import 'enemy.dart';
import 'player.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  final VoidCallback onQuit;
  late Player player;
  late JoystickComponent joystick;
  final List<Enemy> enemies = [];

  MyGame({required this.onQuit});

  @override
  Future<void> onLoad() async {
    // Checkerboard FIRST — renderiza abaixo de tudo
    final tilesX = (size.x / 32).ceil() + 1;
    final tilesY = (size.y / 32).ceil() + 1;
    for (int x = 0; x < tilesX; x++) {
      for (int y = 0; y < tilesY; y++) {
        add(
          RectangleComponent(
            position: Vector2(x * 32.0, y * 32.0),
            size: Vector2(32, 32),
            paint: Paint()
              ..color = (x + y) % 2 == 0
                  ? const Color(0xFF888888)
                  : const Color(0xFF555555),
          ),
        );
      }
    }

    // Joystick virtual
    joystick = JoystickComponent(
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
    add(joystick);

    // Player no centro
    player = Player(joystick)..position = size / 2;
    add(player);

    // 3 inimigos vermelhos — parte superior da tela
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final enemy = Enemy(player, color: Colors.red)
        ..position = Vector2(
          32 + random.nextDouble() * (size.x - 64),
          32 + random.nextDouble() * (size.y * 0.35),
        );
      enemies.add(enemy);
      add(enemy);
    }

    // 1 inimigo amarelo — abaixo do jogador
    final yellowEnemy = Enemy(player, color: Colors.yellow)
      ..position = Vector2(size.x / 2, size.y * 0.8);
    enemies.add(yellowEnemy);
    add(yellowEnemy);
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
