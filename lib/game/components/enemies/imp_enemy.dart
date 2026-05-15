import '../enemy.dart';

class ImpEnemy extends Enemy {
  static const double defaultHeight = 48.0;
  static const String _sprite = 'lib/assets/characteres/imp/imp.png';

  ImpEnemy(
    super.target, {
    required super.speed,
    required super.color,
    required super.onDeath,
    super.initialHp = 20,
    super.targetHeight = defaultHeight,
  });

  @override
  String get spritePath => _sprite;

  @override
  int get framesCount => 4;
}
