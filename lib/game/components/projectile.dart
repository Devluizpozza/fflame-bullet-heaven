import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/services.dart';

import '../game_constants.dart';
import 'interfaces.dart';

class Projectile extends SpriteAnimationComponent with CollisionCallbacks {
  static const double _speed = 400;
  static const double _radius = 8.0;

  final Vector2 _velocity;

  Projectile({required Vector2 position, required Vector2 direction})
      : _velocity = direction.normalized() * _speed,
        super(
          size: Vector2.all(_radius * 2),
          anchor: Anchor.center,
          position: position,
        );

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load('lib/assets/art/projectil_flame.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;

    const frames = 4;
    final frameW = img.width / frames.toDouble();
    final frameH = img.height.toDouble();

    // Mantém proporção do frame; +50% em relação ao radius base
    final scale = (_radius * 3) / frameH;
    size = Vector2(frameW * scale, frameH * scale);

    animation = SpriteAnimation.fromFrameData(
      img,
      SpriteAnimationData.sequenced(
        amount: frames,
        amountPerRow: frames, // 1 linha, 4 colunas
        textureSize: Vector2(frameW, frameH),
        stepTime: 0.08,
        loop: true,
      ),
    );

    paint.filterQuality = ui.FilterQuality.none;
    angle = math.atan2(_velocity.y, _velocity.x);

    add(CircleHitbox(
      radius: _radius * 0.5,
      anchor: Anchor.center,
      position: size / 2,
    ));
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
      final sweepDist = (_velocity * dt).length + _radius;
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
