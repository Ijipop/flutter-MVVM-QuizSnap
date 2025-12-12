import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import '../providers/timer_provider.dart';

// Widget amélioré pour afficher un timer
class TimerWidget extends StatelessWidget {
  final int? secondsRemaining; // Optionnel si on utilise le provider
  final VoidCallback? onTimeUp;
  final bool useProvider; // Utiliser le TimerProvider ou la valeur directe

  const TimerWidget({
    super.key,
    this.secondsRemaining,
    this.onTimeUp,
    this.useProvider = false,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(int seconds, int? initialSeconds) {
    if (initialSeconds == null) {
      return seconds < 10 ? Colors.red : Colors.blue;
    }
    final percentage = seconds / initialSeconds;
    if (percentage < 0.2) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (useProvider) {
      return Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final remaining = timerProvider.remainingSeconds;
          final initial = timerProvider.initialSeconds;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getTimerColor(remaining, initial),
              borderRadius: BorderRadius.circular(20),
              boxShadow: remaining < 10
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Mode direct avec secondsRemaining
    if (secondsRemaining == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimerColor(secondsRemaining!, null),
        borderRadius: BorderRadius.circular(20),
        boxShadow: secondsRemaining! < 10
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(secondsRemaining!),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de timer avec CountdownTimer intégré
class CountdownTimerWidget extends StatelessWidget {
  final int endTime;
  final VoidCallback? onEnd;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const CountdownTimerWidget({
    super.key,
    required this.endTime,
    this.onEnd,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CountdownTimer(
        endTime: endTime,
        onEnd: onEnd,
        textStyle: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

