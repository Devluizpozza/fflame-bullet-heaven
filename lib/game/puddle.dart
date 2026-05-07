import 'dart:ui';

import 'package:flame/components.dart';

class Puddle extends CircleComponent {
  static const double _duration = 6.0;
  static const double _fadeDuration = 1.0;
  static const double _maxOpacity = 0.55;

  final Color _baseColor;
  double _timer = 0;

  Puddle({required Vector2 position, required Color color})
      : _baseColor = color,
        super(
          radius: 28,
          paint: Paint()..color = color.withOpacity(_maxOpacity),
          anchor: Anchor.center,
          position: position,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    final remaining = _duration - _timer;
    if (remaining < _fadeDuration) {
      paint.color = _baseColor.withOpacity(
        (_maxOpacity * remaining / _fadeDuration).clamp(0.0, _maxOpacity),
      );
    }

    if (_timer >= _duration) removeFromParent();
  }
}
