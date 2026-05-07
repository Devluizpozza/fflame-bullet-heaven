import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'enemy.dart';
import 'player.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;
  late JoystickComponent joystick;
  final List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    // Checkerboard FIRST so player/enemies render on top
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

    // Joystick virtual (mobile)
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

    // Player no centro da tela
    player = Player(joystick)..position = size / 2;
    add(player);

    // Inimigos em posições aleatórias
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final enemy = Enemy(player)
        ..position = Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        );
      enemies.add(enemy);
      add(enemy);
    }
  }
}
