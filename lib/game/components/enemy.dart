import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter/services.dart';

import '../game_constants.dart';
import 'interfaces.dart';

enum _HDir { left, right }

class Enemy extends SpriteAnimationComponent with CollisionCallbacks, Hostile, Damageable {
  final PositionComponent target;
  final double speed;
  final Color color;
  final void Function(Vector2 position, Color color) onDeath;
  final int maxHp;
  int hp;

  _HDir? _lastHDir;

  static final _barBgPaint = ui.Paint()..color = const ui.Color(0x99000000);
  static final _barFillPaint = ui.Paint()..color = const ui.Color(0xFF4CAF50);

  final double targetHeight;

  Enemy(
    this.target, {
    required this.speed,
    required this.color,
    required this.onDeath,
    int initialHp = 10,
    this.targetHeight = 48.0,
  })  : maxHp = initialHp,
        hp = initialHp,
        super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load(
      'lib/assets/characteres/goblin/globlin_move_right.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;

    const frames = 4;
    final frameH = img.height / frames.toDouble();
    final s = targetHeight / frameH;
    size = Vector2(img.width * s, targetHeight);

    animation = SpriteAnimation.fromFrameData(
      img,
      SpriteAnimationData.sequenced(
        amount: frames,
        amountPerRow: 1,
        textureSize: Vector2(img.width.toDouble(), frameH),
        stepTime: 0.12,
        loop: true,
      ),
    );

    paint.filterQuality = ui.FilterQuality.none;

    add(RectangleHitbox(
      size: Vector2(size.x * 0.5, size.y * 0.5),
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    _renderHpBar(canvas);
  }

  void _renderHpBar(ui.Canvas canvas) {
    final barW = size.x;
    const barH = 4.0;
    const barY = -10.0;
    final fillW = barW * (hp / maxHp).clamp(0.0, 1.0);

    // Compensa espelho para que a barra sempre preencha da esquerda para direita
    canvas.save();
    if (scale.x < 0) {
      canvas.scale(-1, 1);
      canvas.translate(-size.x, 0);
    }
    canvas.drawRect(ui.Rect.fromLTWH(0, barY, barW, barH), _barBgPaint);
    canvas.drawRect(ui.Rect.fromLTWH(0, barY, fillW, barH), _barFillPaint);
    canvas.restore();
  }

  @override
  void takeDamage(int amount) {
    if (hp <= 0) return;
    hp -= amount;
    if (hp <= 0) {
      onDeath(position.clone(), color);
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dir = target.position - position;
    if (dir.length > 0) {
      dir.normalize();
      position += dir * speed * dt;
      _updateFacing(dir);
    }
    position.x = position.x.clamp(size.x / 2, GameConstants.mapWidth - size.x / 2);
    position.y = position.y.clamp(size.y / 2, GameConstants.mapHeight - size.y / 2);
  }

  void _updateFacing(Vector2 dir) {
    final ax = dir.x.abs();
    final ay = dir.y.abs();
    if (ax >= ay) {
      _lastHDir = dir.x < 0 ? _HDir.left : _HDir.right;
    }
    // Espelha quando vai para esquerda; sem lastHDir ainda usa sprite original
    scale.x = _lastHDir == _HDir.left ? -1 : 1;
  }
}
