import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'enemy.dart';
import 'game_constants.dart';

class Projectile extends CircleComponent with CollisionCallbacks {
  static const double _speed = 400;

  final Vector2 _velocity;

  Projectile({required Vector2 position, required Vector2 direction})
      : _velocity = direction.normalized() * _speed,
        super(
          radius: 5,
          paint: Paint()..color = const Color(0xFFFFAA00),
          anchor: Anchor.center,
          position: position,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;

    // Remove ao sair dos limites do mapa
    if (position.x < 0 ||
        position.x > GameConstants.mapWidth ||
        position.y < 0 ||
        position.y > GameConstants.mapHeight) {
      removeFromParent();
    }
  }
}
