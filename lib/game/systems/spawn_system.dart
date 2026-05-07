import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

import '../components/enemy.dart';
import '../components/puddle.dart';
import '../components/xp_orb.dart';
import '../game_constants.dart';

class SpawnSystem extends Component {
  final PositionComponent playerRef;
  final List<PositionComponent> enemies;
  final void Function() onKill;
  final void Function(int) onXpCollect;

  static const double interval = 3.0;
  static const int countPerWave = 3;
  static const double minDistance = 300.0;
  static const int initialCount = 3;

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

  SpawnSystem({
    required this.playerRef,
    required this.enemies,
    required this.onKill,
    required this.onXpCollect,
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
  }

  void _spawnRandom() {
    _spawnEnemy(
      color: _colors[_random.nextInt(_colors.length)],
      shape: EnemyShape.values[_random.nextInt(EnemyShape.values.length)],
      initialHp: 10 + _random.nextInt(21),
      speed: 50.0 + _random.nextDouble() * 100,
      position: _randomPosition(),
    );
  }

  void _spawnEnemy({
    required Color color,
    required EnemyShape shape,
    required int initialHp,
    required double speed,
    required Vector2 position,
  }) {
    late final Enemy e;
    e = Enemy(
      playerRef,
      speed: speed,
      color: color,
      shape: shape,
      initialHp: initialHp,
      onDeath: (pos, c) {
        enemies.remove(e);
        onKill();
        parent!.add(Puddle(position: pos, color: c));
        if (_random.nextInt(10) < 7) {
          parent!.add(XpOrb(
            position: pos,
            target: playerRef,
            xpValue: e.maxHp,
            color: c,
            onCollect: onXpCollect,
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
