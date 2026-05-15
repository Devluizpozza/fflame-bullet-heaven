import 'dart:math';

import 'package:flame/components.dart';

import '../components/player.dart';
import '../events/game_event_bus.dart';
import '../events/game_events.dart';
import 'skill.dart';
import 'skill_upgrade.dart';

class StormRageSkill extends Skill {
  static const double _baseChance = 0.25;
  static const double _chancePerLevel = 0.10;

  int chanceLevel = 0; // upgrades de "aumentar chance" escolhidos
  int chainLevel = 0;  // upgrades de "aumentar alvos" escolhidos

  double get hitChance => _baseChance + chanceLevel * _chancePerLevel;
  int get chainCount => 1 + chainLevel;

  final void Function(Vector2 origin, int count) onStrike;
  final _random = Random();

  StormRageSkill({required this.onStrike});

  @override
  String get id => 'storm_rage';

  @override
  String get name => 'Storm Rage';

  @override
  String get description => 'Inimigos abatidos têm 25% de chance de atrair um raio em um inimigo aleatório';

  @override
  List<SkillUpgrade> get upgrades => [
        SkillUpgrade(
          name: 'Storm Rage — Tempestade',
          description: '+10% de chance de acionar o raio (atual: ${(hitChance * 100).toStringAsFixed(0)}%)',
          apply: (_) {
            level++;
            chanceLevel++;
          },
        ),
        SkillUpgrade(
          name: 'Storm Rage — Relâmpago',
          description: 'Raio atinge +1 inimigo adicional (atual: $chainCount alvo${chainCount > 1 ? "s" : ""})',
          apply: (_) {
            level++;
            chainLevel++;
          },
        ),
      ];

  @override
  void register(GameEventBus bus) {
    bus.on<EnemyKilledEvent>((event) {
      if (level <= 0) return;
      if (_random.nextDouble() < hitChance) {
        onStrike(event.position, chainCount);
      }
    });
  }

  @override
  void apply(Player player) {
    // Não utilizado diretamente — upgrades têm apply próprio.
    // Implementado para satisfazer o contrato da classe abstrata.
    level++;
  }
}
