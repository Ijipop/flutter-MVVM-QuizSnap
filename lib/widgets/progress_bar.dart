import 'package:flutter/material.dart';

// Widget de barre de progression personnalisée
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 à 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final String? label;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? progressColor.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.bodySmall,
                ),
              if (showPercentage)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

// Widget de barre de progression animée
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final String? label;
  final bool showPercentage;
  final Duration animationDuration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.label,
    this.showPercentage = false,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _targetProgress = widget.progress;
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _targetProgress = widget.progress;
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ProgressBar(
          progress: _animation.value,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          height: widget.height,
          label: widget.label,
          showPercentage: widget.showPercentage,
        );
      },
    );
  }
}

