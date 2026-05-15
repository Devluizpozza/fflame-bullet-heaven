import 'package:flame/components.dart';

abstract class GameEvent {
  const GameEvent();
}

class EnemyKilledEvent extends GameEvent {
  final Vector2 position;
  const EnemyKilledEvent(this.position);
}

class PlayerDamagedEvent extends GameEvent {
  final int amount;
  final int currentHp;
  const PlayerDamagedEvent({required this.amount, required this.currentHp});
}

class LevelUpEvent extends GameEvent {
  final int newLevel;
  const LevelUpEvent(this.newLevel);
}

class MinutePassedEvent extends GameEvent {
  final int minute;
  const MinutePassedEvent(this.minute);
}
