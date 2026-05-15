import '../components/player.dart';
import 'skill.dart';

class ProjectileSpeedSkill extends Skill {
  @override
  String get id => 'attack_speed';

  @override
  String get name => 'Velocidade de Ataque';

  @override
  String get description => 'Aumenta a cadência de disparo';

  @override
  void apply(Player player) {
    level++;
    // Cada nível adiciona 0.5 tiros/segundo, limitado a 10/s
    player.stats.attackSpeed = (0.5 + level * 0.5).clamp(0.5, 10.0);
  }
}
