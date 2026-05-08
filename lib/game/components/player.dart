import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

import '../game_constants.dart';
import 'interfaces.dart';

class Player extends RectangleComponent with KeyboardHandler, CollisionCallbacks {
  final JoystickComponent joystick;
  final List<PositionComponent> targets;
  final void Function(Vector2 position, Vector2 direction) onFire;
  final void Function(int hp)? onHpChanged;
  final void Function()? onDeath;

  static const int maxHp = 20;
  static const double _detectionRadius = 250;
  static const double _flashDuration = 0.3;
  static const Color _normalColor = Color(0xFF2196F3);
  static const Color _hitColor = Color(0xFFE53935);
  static const double _projectileSpacing = 14.0;

  int hp = maxHp;
  double cooldownDuration = 0.4;
  int projectileCount = 1;

  final double speed = 200;
  Vector2 _keyboardVelocity = Vector2.zero();
  double _cooldown = 0;
  double _flashTimer = 0;

  Player(
    this.joystick, {
    required this.targets,
    required this.onFire,
    this.onHpChanged,
    this.onDeath,
  }) : super(
          size: Vector2(32, 32),
          paint: Paint()..color = _normalColor,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void takeDamage(int amount) {
    if (hp <= 0) return;
    hp = (hp - amount).clamp(0, maxHp);
    _flashTimer = _flashDuration;
    paint.color = _hitColor;
    onHpChanged?.call(hp);
    if (hp <= 0) onDeath?.call();
  }

  void heal(int amount) {
    if (hp <= 0 || hp >= maxHp) return;
    hp = (hp + amount).clamp(0, maxHp);
    onHpChanged?.call(hp);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Hostile) takeDamage(1);
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

    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) paint.color = _normalColor;
    }

    if (joystick.direction != JoystickDirection.idle) {
      position += joystick.relativeDelta * speed * dt;
    } else if (_keyboardVelocity.length > 0) {
      position += _keyboardVelocity * speed * dt;
    }

    const half = 16.0;
    position.x = position.x.clamp(half, GameConstants.mapWidth - half);
    position.y = position.y.clamp(half, GameConstants.mapHeight - half);

    _cooldown -= dt;
    if (_cooldown <= 0) {
      final nearest = _nearestTargetInRadius();
      if (nearest != null) {
        _fireAt(nearest.position);
        _cooldown = cooldownDuration;
      }
    }
  }

  void _fireAt(Vector2 targetPos) {
    final dir = (targetPos - position).normalized();
    // Perpendicular ao eixo de disparo, para distribuir projéteis lado a lado
    final perp = Vector2(-dir.y, dir.x);
    final halfSpread = (projectileCount - 1) / 2.0;
    for (int i = 0; i < projectileCount; i++) {
      final offset = perp * ((i - halfSpread) * _projectileSpacing);
      onFire(position.clone() + offset, dir);
    }
  }

  PositionComponent? _nearestTargetInRadius() {
    PositionComponent? nearest;
    double minDist = _detectionRadius;
    for (final t in targets) {
      final dist = (t.position - position).length;
      if (dist < minDist) {
        minDist = dist;
        nearest = t;
      }
    }
    return nearest;
  }
}
