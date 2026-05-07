import 'package:flame/components.dart';

mixin Hostile on PositionComponent {}

mixin Damageable on PositionComponent {
  void takeDamage(int amount);
}
