import 'game_events.dart';

class GameEventBus {
  final _handlers = <Type, List<Function>>{};

  void on<T extends GameEvent>(void Function(T) handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  void emit<T extends GameEvent>(T event) {
    final list = _handlers[T];
    if (list == null) return;
    // copia a lista para permitir que handlers se removam durante a iteração
    for (final h in List.of(list)) {
      (h as void Function(T))(event);
    }
  }
}
