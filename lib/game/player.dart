import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

import 'enemy.dart';
import 'game_constants.dart';

class Player extends RectangleComponent with KeyboardHandler, CollisionCallbacks {
  final JoystickComponent joystick;
  final List<Enemy> enemies;
  final void Function(Vector2 position, Vector2 direction) onFire;

  static const double _detectionRadius = 250;
  static const double _cooldownDuration = 0.5;

  final double speed = 200;
  Vector2 _keyboardVelocity = Vector2.zero();
  double _cooldown = 0;

  Player(
    this.joystick, {
    required this.enemies,
    required this.onFire,
  }) : super(
          size: Vector2(32, 32),
          paint: Paint()..color = const Color(0xFF2196F3),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Stub para sistema de vida: quando inimigo encostar no player
    // if (other is Enemy) { takeDamage(); }
  }

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

    // Movimento
    if (joystick.direction != JoystickDirection.idle) {
      position += joystick.relativeDelta * speed * dt;
    } else if (_keyboardVelocity.length > 0) {
      position += _keyboardVelocity * speed * dt;
    }

    // Colisão com bordas do mapa
    const half = 16.0;
    position.x = position.x.clamp(half, GameConstants.mapWidth - half);
    position.y = position.y.clamp(half, GameConstants.mapHeight - half);

    // Auto-disparo ao inimigo mais próximo dentro do raio
    _cooldown -= dt;
    if (_cooldown <= 0) {
      final target = _nearestEnemyInRadius();
      if (target != null) {
        final direction = target.position - position;
        onFire(position.clone(), direction.normalized());
        _cooldown = _cooldownDuration;
      }
    }
  }

  Enemy? _nearestEnemyInRadius() {
    Enemy? nearest;
    double minDist = _detectionRadius;
    for (final enemy in enemies) {
      final dist = (enemy.position - position).length;
      if (dist < minDist) {
        minDist = dist;
        nearest = enemy;
      }
    }
    return nearest;
  }
}
