import '../components/player.dart';
import '../events/game_event_bus.dart';
import 'skill_upgrade.dart';

abstract class Skill {
  String get id;
  String get name;
  String get description;

  int level = 0;

  /// Caminhos de upgrade disponíveis para esta skill.
  /// Skills de caminho único não precisam fazer override — o default
  /// envolve o próprio apply() automaticamente.
  List<SkillUpgrade> get upgrades => [
        SkillUpgrade(name: name, description: description, apply: apply),
      ];

  /// Chamado uma vez no startup para registrar listeners no bus.
  void register(GameEventBus bus) {}

  /// Chamado quando o jogador seleciona esta skill (ou um de seus upgrades).
  void apply(Player player);
}
