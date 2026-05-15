import 'dart:math';

import 'package:flame/components.dart';

import '../components/player.dart';
import '../events/game_event_bus.dart';
import '../events/game_events.dart';
import 'skill.dart';

class ExplosionOnKillSkill extends Skill {
  static const double _baseRadius = 80.0;
  static const double _baseChance = 0.20;

  final void Function(Vector2 position, double radius, int damage) onExplode;
  final _random = Random();

  ExplosionOnKillSkill({required this.onExplode});

  @override
  String get id => 'explosion_on_kill';

  @override
  String get name => 'Explosão';

  @override
  String get description => 'Inimigos abatidos têm chance de explodir e causar dano aos próximos';

  @override
  void register(GameEventBus bus) {
    bus.on<EnemyKilledEvent>((event) {
      if (level <= 0) return;
      if (_random.nextDouble() < _baseChance * level) {
        onExplode(
          event.position,
          _baseRadius + level * 15,
          10 * level,
        );
      }
    });
  }

  @override
  void apply(Player player) {
    level++;
  }
}
