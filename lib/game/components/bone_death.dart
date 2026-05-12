import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class BoneDeath extends SpriteComponent {
  static const double _duration = 5.0;
  static const double _fadeDuration = 1.5;

  double _timer = 0;

  BoneDeath({required Vector2 position})
      : super(anchor: Anchor.center, position: position);

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load('lib/assets/characteres/goblin/bone_death.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    sprite = Sprite(frame.image);

    final img = frame.image;
    const targetHeight = 48.0;
    final scale = targetHeight / img.height.toDouble();
    size = Vector2(img.width * scale, targetHeight);

    paint.filterQuality = ui.FilterQuality.none;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    final remaining = _duration - _timer;
    if (remaining < _fadeDuration) {
      opacity = (remaining / _fadeDuration).clamp(0.0, 1.0);
    }
    if (_timer >= _duration) removeFromParent();
  }
}
