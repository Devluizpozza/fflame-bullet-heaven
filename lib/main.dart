import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<MyGame>(
          game: MyGame(),
          overlayBuilderMap: {
            'menu': (context, game) => _MenuOverlay(game: game),
          },
          initialActiveOverlays: const ['menu'],
        ),
      ),
    ),
  );
}

class _MenuOverlay extends StatelessWidget {
  final MyGame game;
  const _MenuOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
          ),
          onPressed: () => game.overlays.remove('menu'),
          child: const Text(
            'Jogar',
            style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
