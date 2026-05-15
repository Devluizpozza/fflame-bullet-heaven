import '../components/player.dart';

class SkillUpgrade {
  final String name;
  final String description;
  final void Function(Player player) apply;

  const SkillUpgrade({
    required this.name,
    required this.description,
    required this.apply,
  });
}
