import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

import '../components/bone_death.dart';
import '../components/enemy.dart';
import '../components/health_drop.dart';
import '../components/xp_orb.dart';
import '../game_constants.dart';

class SpawnSystem extends Component {
  final PositionComponent playerRef;
  final List<PositionComponent> enemies;
  final void Function() onKill;
  final void Function(int) onXpCollect;
  final void Function(int) onHealPlayer;
  final void Function() onGrantFullLevel;

  static const double interval = 3.0;
  static const double bossInterval = 10.0;
  static const int countPerWave = 3;
  static const double minDistance = 300.0;
  static const int initialCount = 3;

  static const double _bossTargetHeight = 144.0; // 3x player (48 * 3)
  static const int _bossHp = 150;
  static const double _bossSpeed = 160.0; // 80% de 200

  static const _colors = <Color>[
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.cyan,
    Colors.purple,
    Colors.pink,
    Colors.lightBlue,
    Colors.lightGreen,
  ];

  final _random = Random();
  double _timer = 0;
  double _bossTimer = 0;

  SpawnSystem({
    required this.playerRef,
    required this.enemies,
    required this.onKill,
    required this.onXpCollect,
    required this.onHealPlayer,
    required this.onGrantFullLevel,
  });

  @override
  void onMount() {
    super.onMount();
    for (int i = 0; i < initialCount; i++) {
      _spawnRandom();
    }
  }

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= interval) {
      _timer -= interval;
      for (int i = 0; i < countPerWave; i++) {
        _spawnRandom();
      }
    }

    _bossTimer += dt;
    if (_bossTimer >= bossInterval) {
      _bossTimer -= bossInterval;
      _spawnGiant();
    }
  }

  void _spawnRandom() {
    _spawnEnemy(
      color: _colors[_random.nextInt(_colors.length)],
      initialHp: 10 + _random.nextInt(21),
      speed: 50.0 + _random.nextDouble() * 100,
      position: _randomPosition(),
    );
  }

  void _spawnGiant() {
    late final Enemy e;
    e = Enemy(
      playerRef,
      speed: _bossSpeed,
      color: const Color(0xFFFFD700),
      initialHp: _bossHp,
      targetHeight: _bossTargetHeight,
      onDeath: (pos, _) {
        enemies.remove(e);
        onKill();

        // 1 vida garantida
        parent!.add(HealthDrop(
          position: pos,
          target: playerRef,
          onCollect: () => onHealPlayer(4),
        ));

        // 5 orbs de 100 XP cada
        for (int i = 0; i < 5; i++) {
          final offset = Vector2(
            (_random.nextDouble() - 0.5) * 60,
            (_random.nextDouble() - 0.5) * 60,
          );
          parent!.add(XpOrb(
            position: pos + offset,
            target: playerRef,
            xpValue: 100,
            color: const Color(0xFFFFD700),
            onCollect: onXpCollect,
          ));
        }

        // 1 nível completo
        onGrantFullLevel();

        parent!.add(BoneDeath(position: pos, targetHeight: _bossTargetHeight * 0.25));
      },
    )..position = _randomPosition();
    enemies.add(e);
    parent!.add(e);
  }

  void _spawnEnemy({
    required Color color,
    required int initialHp,
    required double speed,
    required Vector2 position,
  }) {
    late final Enemy e;
    e = Enemy(
      playerRef,
      speed: speed,
      color: color,
      initialHp: initialHp,
      onDeath: (pos, c) {
        enemies.remove(e);
        onKill();
        parent!.add(BoneDeath(position: pos));
        if (_random.nextInt(10) < 7) {
          parent!.add(XpOrb(
            position: pos,
            target: playerRef,
            xpValue: e.maxHp,
            color: c,
            onCollect: onXpCollect,
          ));
        }
        if (_random.nextInt(10) == 0) {
          parent!.add(HealthDrop(
            position: pos,
            target: playerRef,
            onCollect: () => onHealPlayer(4),
          ));
        }
      },
    )..position = position;
    enemies.add(e);
    parent!.add(e);
  }

  Vector2 _randomPosition() {
    Vector2 pos;
    var tries = 0;
    do {
      pos = Vector2(
        _random.nextDouble() * GameConstants.mapWidth,
        _random.nextDouble() * GameConstants.mapHeight,
      );
      tries++;
    } while ((pos - playerRef.position).length < minDistance && tries < 20);
    return pos;
  }
}
