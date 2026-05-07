import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

import 'game_constants.dart';
import 'player.dart';

enum EnemyShape { circle, square, triangle }

class Enemy extends PositionComponent with CollisionCallbacks {
  final Player player;
  final double speed;
  final void Function(Vector2 position, Color color) onDeath;
  final EnemyShape shape;
  final Color _color;
  final Paint _paint;
  final int maxHp;
  int hp;

  static const double _unitSize = 32.0;
  static final _barBgPaint = Paint()..color = const Color(0x99000000);
  static final _barFillPaint = Paint()..color = const Color(0xFF4CAF50);

  Enemy(
    this.player, {
    required this.speed,
    required this.onDeath,
    required this.shape,
    Color color = Colors.red,
    int initialHp = 10,
  })  : _color = color,
        _paint = Paint()..color = color,
        maxHp = initialHp,
        hp = initialHp,
        super(
          size: Vector2.all(_unitSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    switch (shape) {
      case EnemyShape.circle:
        add(CircleHitbox());
      case EnemyShape.square:
        add(RectangleHitbox());
      case EnemyShape.triangle:
        // Hitbox circular aproximado para o triângulo
        add(CircleHitbox(radius: 14));
    }
  }

  @override
  void render(Canvas canvas) {
    switch (shape) {
      case EnemyShape.circle:
        canvas.drawCircle(const Offset(16, 16), 16, _paint);
      case EnemyShape.square:
        canvas.drawRect(const Rect.fromLTWH(2, 2, 28, 28), _paint);
      case EnemyShape.triangle:
        final path = Path()
          ..moveTo(16, 0)
          ..lineTo(0, 32)
          ..lineTo(32, 32)
          ..close();
        canvas.drawPath(path, _paint);
    }
    _renderHpBar(canvas);
  }

  void _renderHpBar(Canvas canvas) {
    const barW = 30.0;
    const barH = 4.0;
    const barX = 1.0;
    const barY = -7.0;

    canvas.drawRect(
      const Rect.fromLTWH(barX, barY, barW, barH),
      _barBgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barW * (hp / maxHp).clamp(0.0, 1.0), barH),
      _barFillPaint,
    );
  }

  void takeDamage(int amount) {
    if (hp <= 0) return;
    hp -= amount;
    if (hp <= 0) {
      onDeath(position.clone(), _color);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = player.position - position;
    if (direction.length > 0) {
      direction.normalize();
      position += direction * speed * dt;
    }

    const half = _unitSize / 2;
    position.x = position.x.clamp(half, GameConstants.mapWidth - half);
    position.y = position.y.clamp(half, GameConstants.mapHeight - half);
  }
}
