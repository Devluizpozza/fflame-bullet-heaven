import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import '../game_constants.dart';
import 'interfaces.dart';

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
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Damageable) {
      other.takeDamage(3);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final origin = position.clone();
    position += _velocity * dt;

    // CCD: varre o caminho percorrido neste frame para evitar tunneling
    final world = parent;
    if (world is HasCollisionDetection && isMounted) {
      final dir = _velocity.normalized();
      final sweepDist = (_velocity * dt).length + radius;
      final ray = Ray2(origin: origin, direction: dir);
      final ownHitboxes = children.query<ShapeHitbox>().toList();
      final cd = world.collisionDetection;
      final result = cd is StandardCollisionDetection
          ? cd.raycast(ray, maxDistance: sweepDist, ignoreHitboxes: ownHitboxes)
          : null;
      if (result != null && result.isActive) {
        final hit = result.hitbox?.parent;
        if (hit is Damageable) {
          hit.takeDamage(3);
          removeFromParent();
          return;
        }
      }
    }

    if (position.x < 0 ||
        position.x > GameConstants.mapWidth ||
        position.y < 0 ||
        position.y > GameConstants.mapHeight) {
      removeFromParent();
    }
  }
}
