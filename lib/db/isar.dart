import 'package:isar/isar.dart';

@collection
class PlayerData {
  Id id = Isar.autoIncrement;

  int gold = 0;
  int level = 1;
}
