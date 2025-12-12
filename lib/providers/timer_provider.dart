import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';

// Provider pour gérer le timer du quiz
class TimerProvider with ChangeNotifier {
  CountdownTimerController? _controller;
  int _endTime = 0;
  int _initialSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _pausedRemainingSeconds = 0;
  VoidCallback? _onTimeUp;
  Timer? _updateTimer;

  // Getters
  CountdownTimerController? get controller => _controller;
  int get endTime => _endTime;
  int get initialSeconds => _initialSeconds;
  int get remainingSeconds {
    if (!_isRunning || _isPaused) {
      return _pausedRemainingSeconds;
    }
    if (_endTime == 0) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((_endTime - now) / 1000).ceil();
    final result = remaining.clamp(0, _initialSeconds);
    if (result <= 0 && _isRunning) {
      _isRunning = false;
      _onTimeUp?.call();
      notifyListeners();
    }
    return result;
  }

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isExpired => remainingSeconds <= 0 && _isRunning;

  // Initialiser le timer
  void startTimer(int seconds, {VoidCallback? onTimeUp}) {
    _initialSeconds = seconds;
    _onTimeUp = onTimeUp;
    _isRunning = true;
    _isPaused = false;
    _pausedRemainingSeconds = 0;

    // Calculer le temps de fin
    _endTime = DateTime.now().add(Duration(seconds: seconds)).millisecondsSinceEpoch;

    // Créer le controller pour le widget CountdownTimer
    _controller = CountdownTimerController(
      endTime: _endTime,
      onEnd: () {
        _isRunning = false;
        _onTimeUp?.call();
        notifyListeners();
      },
    );

    // Démarrer un timer pour mettre à jour l'UI chaque seconde
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning || _isPaused) {
        timer.cancel();
        return;
      }
      final remaining = remainingSeconds;
      if (remaining <= 0) {
        timer.cancel();
        _isRunning = false;
        _onTimeUp?.call();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  // Mettre en pause le timer
  void pauseTimer() {
    if (_isRunning && !_isPaused) {
      _isPaused = true;
      _pausedRemainingSeconds = remainingSeconds;
      _updateTimer?.cancel();
      notifyListeners();
    }
  }

  // Reprendre le timer
  void resumeTimer() {
    if (_isRunning && _isPaused) {
      _isPaused = false;
      // Recalculer le temps de fin basé sur le temps restant
      _endTime = DateTime.now().add(Duration(seconds: _pausedRemainingSeconds)).millisecondsSinceEpoch;
      
      // Recréer le controller avec le nouveau temps de fin
      _controller?.dispose();
      _controller = CountdownTimerController(
        endTime: _endTime,
        onEnd: () {
          _isRunning = false;
          _onTimeUp?.call();
          notifyListeners();
        },
      );

      // Redémarrer le timer de mise à jour
      _updateTimer?.cancel();
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isRunning || _isPaused) {
          timer.cancel();
          return;
        }
        final remaining = remainingSeconds;
        if (remaining <= 0) {
          timer.cancel();
          _isRunning = false;
          _onTimeUp?.call();
        }
        notifyListeners();
      });

      notifyListeners();
    }
  }

  // Arrêter le timer
  void stopTimer() {
    _isRunning = false;
    _isPaused = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _controller?.dispose();
    _controller = null;
    _endTime = 0;
    _pausedRemainingSeconds = 0;
    _onTimeUp = null;
    notifyListeners();
  }

  // Réinitialiser le timer
  void resetTimer(int seconds, {VoidCallback? onTimeUp}) {
    stopTimer();
    startTimer(seconds, onTimeUp: onTimeUp);
  }

  // Ajouter du temps (pour les power-ups)
  void addTime(int seconds) {
    if (_isRunning && !_isPaused) {
      _endTime += seconds * 1000;
      _controller?.dispose();
      _controller = CountdownTimerController(
        endTime: _endTime,
        onEnd: () {
          _isRunning = false;
          _onTimeUp?.call();
          notifyListeners();
        },
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

