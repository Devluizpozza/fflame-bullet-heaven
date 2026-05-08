import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Oculta status bar e navigation bar — jogo ocupa a tela toda
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarDividerColor: Colors.black,
  ));
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
      backgroundColor: Colors.black,
      body: GameWidget<MyGame>(
        key: ValueKey(_gameKey),
        game: _game,
        overlayBuilderMap: {
          'menu': (_, game) => _MenuOverlay(game: game),
          'hud': (_, game) => _HudOverlay(game: game),
          'pause': (_, game) => _PauseOverlay(game: game),
          'gameover': (_, game) => _GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['menu'],
      ),
    );
  }
}

// ─── Menu ────────────────────────────────────────────────────────────────────

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

// ─── HUD ─────────────────────────────────────────────────────────────────────

class _HudOverlay extends StatelessWidget {
  final MyGame game;
  const _HudOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Barra de vida do player — topo centralizado
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ValueListenableBuilder<(int, int, int)>(
                valueListenable: game.xpNotifier,
                builder: (_, xpTuple, __) => ValueListenableBuilder<int>(
                  valueListenable: game.playerHpNotifier,
                  builder: (_, hp, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Lv${xpTuple.$3}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlayerHpBar(hp: hp, maxHp: game.playerMaxHp),
                          const SizedBox(height: 4),
                          _XpBar(current: xpTuple.$1, required: xpTuple.$2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botão de pause — topo direito
          Align(
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
        ],
      ),
    );
  }
}

class _PlayerHpBar extends StatelessWidget {
  final int hp;
  final int maxHp;
  const _PlayerHpBar({required this.hp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    final Color fillColor = ratio > 0.5
        ? Colors.green
        : ratio > 0.25
            ? Colors.orange
            : Colors.red;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$hp / $maxHp',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 180,
          height: 14,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(7),
          ),
          child: FractionallySizedBox(
            widthFactor: ratio,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _XpBar extends StatelessWidget {
  final int current;
  final int required;
  const _XpBar({required this.current, required this.required});

  @override
  Widget build(BuildContext context) {
    final ratio = required > 0 ? (current / required).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: 180,
      height: 10,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        widthFactor: ratio,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

// ─── Pause ───────────────────────────────────────────────────────────────────

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
              child: const Text('Continuar',
                  style: TextStyle(fontSize: 24, color: Colors.black)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
              ),
              onPressed: game.quitGame,
              child: const Text('Sair',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Game Over ───────────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final MyGame game;
  const _GameOverOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Inimigos eliminados: ${game.killCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 22),
              ),
              onPressed: game.quitGame,
              child: const Text(
                'Sair',
                style: TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
