import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _GameApp(),
  ));
}

class _GameApp extends StatefulWidget {
  const _GameApp();
  @override
  State<_GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<_GameApp> {
  late MyGame _game;
  int _gameKey = 0;

  @override
  void initState() {
    super.initState();
    _game = MyGame(onQuit: _restart);
  }

  void _restart() {
    setState(() {
      _gameKey++;
      _game = MyGame(onQuit: _restart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<MyGame>(
        key: ValueKey(_gameKey),
        game: _game,
        overlayBuilderMap: {
          'menu': (_, game) => _MenuOverlay(game: game),
          'hud': (_, game) => _HudOverlay(game: game),
          'pause': (_, game) => _PauseOverlay(game: game),
        },
        initialActiveOverlays: const ['menu'],
      ),
    );
  }
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
          onPressed: () {
            game.overlays.remove('menu');
            game.overlays.add('hud');
          },
          child: const Text(
            'Jogar',
            style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  final MyGame game;
  const _HudOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: game.pauseGame,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pause, color: Colors.black, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final MyGame game;
  const _PauseOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
              ),
              onPressed: game.resumeGame,
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
              ),
              onPressed: game.quitGame,
              child: const Text(
                'Sair',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
