import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player.dart';

class XpOrb extends CircleComponent with CollisionCallbacks {
  final Player player;
  final int xpValue;
  final void Function(int) onCollect;

  static const double _attractRadius = 130;
  static const double _speed = 210;
  static final _shinePaint = Paint()..color = const Color(0x70FFFFFF);

  XpOrb({
    required Vector2 position,
    required this.player,
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
    // Brilho de diamante no canto superior esquerdo
    canvas.drawCircle(
      Offset(radius * 0.38, radius * 0.38),
      radius * 0.32,
      _shinePaint,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      onCollect(xpValue);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final toPlayer = player.position - position;
    if (toPlayer.length < _attractRadius && toPlayer.length > 0) {
      position += toPlayer.normalized() * _speed * dt;
    }
  }
}
