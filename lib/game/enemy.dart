import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class Enemy extends CircleComponent with HasGameRef<FlameGame> {
  final Player player;
  final double speed = 65;

  Enemy(this.player, {Color color = Colors.red})
      : super(
          radius: 16,
          paint: Paint()..color = color,
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

    // Impede sair da tela
    position.x = position.x.clamp(radius, gameRef.size.x - radius);
    position.y = position.y.clamp(radius, gameRef.size.y - radius);
  }
}
