import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'player.dart';
import 'enemy.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;
  final List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(Vector2(800, 600));

    // Player
    player = Player()
      ..position = Vector2(400, 300);
    add(player);

    // Enemies
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final enemy = Enemy(player)
        ..position = Vector2(
          random.nextDouble() * 800,
          random.nextDouble() * 600,
        );
      enemies.add(enemy);
      add(enemy);
    }

    for (int x = 0; x < 25; x++) {
  for (int y = 0; y < 19; y++) {
    add(
      RectangleComponent(
        position: Vector2(x * 32, y * 32),
        size: Vector2(32, 32),
        paint: Paint()
          ..color = (x + y) % 2 == 0
              ? const Color(0xFFEEEEEE)
              : const Color(0xFFCCCCCC),
      ),
    );
  }
}
  }
}