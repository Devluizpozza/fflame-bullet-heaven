import 'package:flutter/foundation.dart' show ValueNotifier;

class XpSystem {
  int level = 1;
  int currentXp = 0;
  late final ValueNotifier<(int, int, int)> notifier;
  final void Function()? onLevelUp;

  XpSystem({this.onLevelUp}) {
    notifier = ValueNotifier((0, xpRequired, 1));
  }

  int get xpRequired => 10 << (level - 1);

  void collect(int amount) {
    currentXp += amount;
    while (currentXp >= xpRequired) {
      currentXp -= xpRequired;
      level++;
      onLevelUp?.call();
    }
    notifier.value = (currentXp, xpRequired, level);
  }
}
