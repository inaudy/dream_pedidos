import 'dart:async';

class EventBus {
  static final EventBus _singleton = EventBus._internal();
  final StreamController<String> _controller = StreamController.broadcast();

  factory EventBus() {
    return _singleton;
  }

  EventBus._internal();

  Stream<String> get stream => _controller.stream;

  void emit(String event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

final eventBus = EventBus();
