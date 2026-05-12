import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../game_constants.dart';

class GameWorld extends World with HasCollisionDetection {}

class TiledBackground extends PositionComponent {
  late Paint _paint;

  TiledBackground()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.mapWidth, GameConstants.mapHeight),
        );

  @override
  Future<void> onLoad() async {
    final data = await rootBundle.load('lib/assets/tiles/dirty_floor.png');
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final tile = frame.image;

    _paint = Paint()
      ..filterQuality = FilterQuality.none
      ..shader = ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList([
          1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        ]),
      );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
      _paint,
    );
  }
}
