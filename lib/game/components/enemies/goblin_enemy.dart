import 'package:flutter/material.dart' show Color;
import 'package:flame/components.dart';

import '../enemy.dart';

class GoblinEnemy extends Enemy {
  static const double defaultHeight = 48.0;
  static const String _sprite = 'lib/assets/characteres/goblin/globlin_move_right.png';

  GoblinEnemy(
    super.target, {
    required super.speed,
    required super.color,
    required super.onDeath,
    super.initialHp = 10,
    super.targetHeight = defaultHeight,
  });

  @override
  String get spritePath => _sprite;

  @override
  int get framesCount => 4;
}
