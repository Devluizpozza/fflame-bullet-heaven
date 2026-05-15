import '../components/player.dart';
import '../events/game_event_bus.dart';

abstract class Skill {
  String get id;
  String get name;
  String get description;

  int level = 0;

  /// Chamado uma vez no startup para registrar listeners no bus.
  /// Skills que não reagem a eventos deixam este método sem override.
  void register(GameEventBus bus) {}

  /// Chamado toda vez que o jogador seleciona esta habilidade no level-up.
  void apply(Player player);
}
