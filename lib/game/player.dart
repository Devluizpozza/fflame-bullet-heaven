import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

import 'game_constants.dart';

class Player extends RectangleComponent with KeyboardHandler {
  final JoystickComponent joystick;
  final double speed = 200;
  Vector2 _keyboardVelocity = Vector2.zero();

  Player(this.joystick)
    : super(
        size: Vector2(32, 32),
        paint: Paint()..color = const Color(0xFF2196F3),
        anchor: Anchor.center,
      );

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardVelocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) _keyboardVelocity.y = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) _keyboardVelocity.y = 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) _keyboardVelocity.x = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) _keyboardVelocity.x = 1;

    if (_keyboardVelocity.length > 0) _keyboardVelocity.normalize();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick.direction != JoystickDirection.idle) {
      position += joystick.relativeDelta * speed * dt;
    } else if (_keyboardVelocity.length > 0) {
      position += _keyboardVelocity * speed * dt;
    }

    // Colisão com as bordas do mapa
    const half = 16.0;
    position.x = position.x.clamp(half, GameConstants.mapWidth - half);
    position.y = position.y.clamp(half, GameConstants.mapHeight - half);
  }
}
