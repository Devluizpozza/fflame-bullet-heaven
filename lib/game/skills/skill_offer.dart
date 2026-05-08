import 'package:flutter/foundation.dart' show VoidCallback;

class SkillOffer {
  final String title;
  final String description;
  final int nextLevel;
  final VoidCallback onSelect;

  const SkillOffer({
    required this.title,
    required this.description,
    required this.nextLevel,
    required this.onSelect,
  });
}
