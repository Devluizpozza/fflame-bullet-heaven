import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class Enemy extends CircleComponent {
  final Player player;
  final double speed = 100;

  Enemy(this.player)
      : super(
          radius: 16,
          paint: Paint()..color = Colors.red,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    final direction = player.position - position;

    if (direction.length > 0) {
      direction.normalize();
      position += direction * speed * dt;
    }
  }
}
