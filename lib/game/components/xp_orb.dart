import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class XpOrb extends PositionComponent with CollisionCallbacks {
  final PositionComponent target;
  final int xpValue;
  final void Function(int) onCollect;

  static const double _attractRadius = 130;
  static const double _speed = 210;
  static final _shinePaint = Paint()..color = const Color(0x70FFFFFF);

  late final Paint _fillPaint;
  late final _OrbTier _tier;

  XpOrb({
    required Vector2 position,
    required this.target,
    required this.xpValue,
    required Color color, // mantido por compatibilidade, tier sobrescreve visualmente
    required this.onCollect,
  }) : super(anchor: Anchor.center, position: position) {
    _tier = xpValue > 30
        ? _OrbTier.orange
        : xpValue > 20
            ? _OrbTier.purple
            : _OrbTier.blue;

    final orbColor = switch (_tier) {
      _OrbTier.blue => const Color(0xFF42A5F5),
      _OrbTier.purple => const Color(0xFFAB47BC),
      _OrbTier.orange => const Color(0xFFFF7043),
    };
    _fillPaint = Paint()..color = orbColor;
    size = Vector2.all(_tier == _OrbTier.orange ? 13 : _tier == _OrbTier.purple ? 11 : 9);
  }

  @override
  Future<void> onLoad() async {
    final r = size.x / 2;
    add(CircleHitbox(radius: r, anchor: Anchor.center, position: size / 2));
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x / 2;

    switch (_tier) {
      case _OrbTier.blue:
        // Diamante (quadrado 45°)
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, _fillPaint);
        // brilho interno
        final shinePath = Path()
          ..moveTo(cx - r * 0.15, cy - r * 0.55)
          ..lineTo(cx + r * 0.15, cy - r * 0.3)
          ..lineTo(cx - r * 0.05, cy - r * 0.1)
          ..close();
        canvas.drawPath(shinePath, _shinePaint);
      case _OrbTier.purple:
        // Círculo com borda
        canvas.drawCircle(Offset(cx, cy), r, _fillPaint);
        canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.3), r * 0.25, _shinePaint);
      case _OrbTier.orange:
        // Círculo maior com brilho
        canvas.drawCircle(Offset(cx, cy), r, _fillPaint);
        // anel externo
        final ringPaint = Paint()
          ..color = const Color(0xFFFFCC02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset(cx, cy), r - 0.75, ringPaint);
        canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.28), r * 0.22, _shinePaint);
    }
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

enum _OrbTier { blue, purple, orange }
