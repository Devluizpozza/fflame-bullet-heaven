import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class XpOrb extends CircleComponent with CollisionCallbacks {
  final PositionComponent target;
  final int xpValue;
  final void Function(int) onCollect;

  static const double _attractRadius = 130;
  static const double _speed = 210;
  static final _shinePaint = Paint()..color = const Color(0x70FFFFFF);

  XpOrb({
    required Vector2 position,
    required this.target,
    required this.xpValue,
    required Color color,
    required this.onCollect,
  }) : super(
          radius: 5,
          paint: Paint()..color = color,
          anchor: Anchor.center,
          position: position,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(
      radius: 5,
      anchor: Anchor.center,
      position: Vector2(5, 5),
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
      Offset(radius * 0.38, radius * 0.38),
      radius * 0.32,
      _shinePaint,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == target) {
      onCollect(xpValue);
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
