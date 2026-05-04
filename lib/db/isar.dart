import 'package:isar/isar.dart';

part 'player_data.g.dart';

@collection
class PlayerData {
  Id id = Isar.autoIncrement;

  int gold = 0;
  int level = 1;
}