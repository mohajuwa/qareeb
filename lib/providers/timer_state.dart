import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ✅ FIXED: Create a separate class for TickerProvider
class TimerTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class TimerState extends ChangeNotifier {
  final TimerTickerProvider _tickerProvider = TimerTickerProvider();

  AnimationController? _controller;
  Animation<Color?>? _colorAnimation;
  int _durationInSeconds = 0;
  Timer? _countdownTimer;
  Timer? _socketReconnectTimer;
  bool _isControllerDisposed = false;
  bool _isAnimation = false;

  // Getters
  AnimationController? get controller => _controller;
  Animation<Color?>? get colorAnimation => _colorAnimation;
  int get durationInSeconds => _durationInSeconds;
  Timer? get countdownTimer => _countdownTimer;
  bool get isControllerDisposed => _isControllerDisposed;
  bool get isAnimation => _isAnimation;

  void initializeController(int duration) {
    disposeController(); // Clean up any existing controller

    _durationInSeconds = duration;
    _controller = AnimationController(
      vsync: _tickerProvider,
      duration: Duration(seconds: duration),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_controller!);

    _isControllerDisposed = false;
    _isAnimation = false;
    notifyListeners();
  }

  void startAnimation() {
    if (_controller != null && !_isControllerDisposed) {
      _isAnimation = true;
      _controller!.forward();
      notifyListeners();
    }
  }

  void stopAnimation() {
    if (_controller != null && !_isControllerDisposed) {
      _isAnimation = false;
      _controller!.stop();
      notifyListeners();
    }
  }

  void resetAnimation() {
    if (_controller != null && !_isControllerDisposed) {
      _controller!.reset();
      _isAnimation = false;
      notifyListeners();
    }
  }

  void startCountdownTimer(Function(Timer) callback) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), callback);
  }

  void cancelCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void startSocketReconnectTimer(Function() callback) {
    _socketReconnectTimer?.cancel();
    _socketReconnectTimer = Timer(const Duration(seconds: 2), callback);
  }

  void cancelSocketReconnectTimer() {
    _socketReconnectTimer?.cancel();
    _socketReconnectTimer = null;
  }

  void disposeController() {
    if (_controller != null && !_isControllerDisposed) {
      _controller!.dispose();
      _isControllerDisposed = true;
      _isAnimation = false;
    }
    cancelCountdownTimer();
    cancelSocketReconnectTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}
