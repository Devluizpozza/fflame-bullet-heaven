import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'game_constants.dart';
import 'player.dart';

class Enemy extends CircleComponent {
  final Player player;
  final double speed;

  Enemy(this.player, {required this.speed, Color color = Colors.red})
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

    // Colisão com as bordas do mapa
    position.x = position.x.clamp(radius, GameConstants.mapWidth - radius);
    position.y = position.y.clamp(radius, GameConstants.mapHeight - radius);
  }
}
