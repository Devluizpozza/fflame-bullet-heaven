import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;

class HealthDrop extends SpriteComponent with CollisionCallbacks {
  final PositionComponent target;
  final void Function() onCollect;

  static const double _attractRadius = 80;
  static const double _speed = 150;

  HealthDrop({
    required Vector2 position,
    required this.target,
    required this.onCollect,
  }) : super(
          size: Vector2.all(20),
          anchor: Anchor.center,
          position: position,
        );

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load('lib/assets/art/hearth_life.png');
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    sprite = Sprite(frame.image);
    add(CircleHitbox(
      radius: 10,
      anchor: Anchor.center,
      position: Vector2(10, 10),
    ));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == target) {
      onCollect();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final toTarget = target.position - position;
    if (toTarget.length < _attractRadius && toTarget.length > 0) {
      position += toTarget.normalized() * _speed * dt;
    }
  }
}
