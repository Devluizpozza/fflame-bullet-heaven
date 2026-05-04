import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class Player extends RectangleComponent with KeyboardHandler {
  final double speed = 200;
  Vector2 velocity = Vector2.zero();

  Player()
      : super(
          size: Vector2(32, 32),
          paint: Paint()..color = const Color(0xFF0000FF),
        );

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      velocity.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      velocity.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x = 1;
    }

    velocity.normalize();

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * speed * dt;
  }
}