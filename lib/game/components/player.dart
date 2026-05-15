import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../game_constants.dart';
import '../player_stats.dart';
import 'interfaces.dart';

enum _HDir { left, right }

class Player extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks {
  final PlayerStats stats;
  final JoystickComponent joystick;
  final List<PositionComponent> targets;
  final void Function(Vector2 position, Vector2 direction) onFire;
  final void Function(int hp)? onHpChanged;
  final void Function(int amount, int currentHp)? onDamaged;
  final void Function()? onDeath;

  static const double _detectionRadius = 250;
  static const double _flashDuration = 0.3;
  static const double _projectileSpacing = 14.0;

  static const _hitColorFilter = ui.ColorFilter.mode(
    ui.Color(0x66FF0000),
    ui.BlendMode.srcATop,
  );

  int get maxHp => stats.maxHp.toInt();
  late int hp;
  int projectileCount = 1;

  Vector2 _keyboardVelocity = Vector2.zero();
  double _cooldown = 0;
  double _flashTimer = 0;
  _HDir? _lastHDir;

  late SpriteAnimation _animIdle;
  late SpriteAnimation _animMoveLeft;
  late SpriteAnimation _animMoveRight;

  Player(
    this.joystick, {
    required this.stats,
    required this.targets,
    required this.onFire,
    this.onHpChanged,
    this.onDamaged,
    this.onDeath,
  }) : super(anchor: Anchor.center) {
    hp = stats.maxHp.toInt();
  }

  @override
  Future<void> onLoad() async {
    _animIdle = await _loadAnim('lib/assets/characteres/idle_player.png', 3);
    _animMoveLeft =
        await _loadAnim('lib/assets/characteres/player_move_left.png', 4);
    _animMoveRight =
        await _loadAnim('lib/assets/characteres/player_move_right.png', 4);

    final data =
        await rootBundle.load('lib/assets/characteres/idle_player.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    const targetHeight = 48.0;
    final s = targetHeight / (img.height / 3.0);
    size = Vector2(img.width * s, targetHeight);

    animation = _animIdle;
    paint.filterQuality = ui.FilterQuality.none;

    add(RectangleHitbox(
      size: Vector2(size.x * 0.5, size.y * 0.5),
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  Future<SpriteAnimation> _loadAnim(String path, int frames) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    return SpriteAnimation.fromFrameData(
      img,
      SpriteAnimationData.sequenced(
        amount: frames,
        amountPerRow: 1,
        textureSize:
            Vector2(img.width.toDouble(), img.height / frames.toDouble()),
        stepTime: 0.12,
        loop: true,
      ),
    );
  }

  void _updateAnimation(Vector2 moveDir) {
    final SpriteAnimation next;
    if (moveDir.isZero()) {
      next = _animIdle;
    } else {
      final ax = moveDir.x.abs();
      final ay = moveDir.y.abs();
      if (ax >= ay) {
        _lastHDir = moveDir.x < 0 ? _HDir.left : _HDir.right;
      }
      next = switch (_lastHDir) {
        _HDir.left => _animMoveLeft,
        _HDir.right => _animMoveRight,
        null => _animIdle,
      };
    }

    scale.x = (next == _animIdle && _lastHDir == _HDir.left) ? -1 : 1;

    if (animation != next) animation = next;
  }

  void takeDamage(int amount) {
    if (hp <= 0) return;
    hp = (hp - amount).clamp(0, maxHp);
    _flashTimer = _flashDuration;
    paint.colorFilter = _hitColorFilter;
    onHpChanged?.call(hp);
    onDamaged?.call(amount, hp);
    if (hp <= 0) onDeath?.call();
  }

  void heal(int amount) {
    if (hp <= 0 || hp >= maxHp) return;
    hp = (hp + amount).clamp(0, maxHp);
    onHpChanged?.call(hp);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Hostile) takeDamage(1);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardVelocity = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp))
      _keyboardVelocity.y = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown))
      _keyboardVelocity.y = 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft))
      _keyboardVelocity.x = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight))
      _keyboardVelocity.x = 1;
    if (_keyboardVelocity.length > 0) _keyboardVelocity.normalize();
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) paint.colorFilter = null;
    }

    Vector2 moveDir = Vector2.zero();
    if (joystick.direction != JoystickDirection.idle) {
      final delta = joystick.relativeDelta;
      if (delta.length > 0.15) moveDir = delta;
    } else if (_keyboardVelocity.length > 0) {
      moveDir = _keyboardVelocity;
    }

    if (!moveDir.isZero()) {
      position += moveDir * stats.moveSpeed * dt;
    }

    _updateAnimation(moveDir);

    position.x =
        position.x.clamp(size.x / 2, GameConstants.mapWidth - size.x / 2);
    position.y =
        position.y.clamp(size.y / 2, GameConstants.mapHeight - size.y / 2);

    _cooldown -= dt;
    if (_cooldown <= 0) {
      final nearest = _nearestTargetInRadius();
      if (nearest != null) {
        _fireAt(nearest.position);
        _cooldown = 1.0 / stats.attackSpeed;
      }
    }
  }

  void _fireAt(Vector2 targetPos) {
    final dir = (targetPos - position).normalized();
    final perp = Vector2(-dir.y, dir.x);
    final halfSpread = (projectileCount - 1) / 2.0;
    for (int i = 0; i < projectileCount; i++) {
      final offset = perp * ((i - halfSpread) * _projectileSpacing);
      onFire(position.clone() + offset, dir);
    }
  }

  PositionComponent? _nearestTargetInRadius() {
    PositionComponent? nearest;
    double minDist = _detectionRadius;
    for (final t in targets) {
      final dist = (t.position - position).length;
      if (dist < minDist) {
        minDist = dist;
        nearest = t;
      }
    }
    return nearest;
  }
}
