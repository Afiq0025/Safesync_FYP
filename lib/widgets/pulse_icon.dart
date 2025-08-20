import 'dart:math' as math;
import 'package:flutter/material.dart';

class PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color pulseColor;
  final Color iconColor;
  final double iconSize;
  final double innerSize; // Diameter of the circle directly behind the icon
  final double pulseSize; // Max diameter of the largest pulse
  final int pulseCount;
  final Duration pulseDuration;

  const PulseIcon({
    Key? key,
    required this.icon,
    this.pulseColor = Colors.blue,
    this.iconColor = Colors.white,
    this.iconSize = 24.0,
    this.innerSize = 40.0,
    this.pulseSize = 100.0,
    this.pulseCount = 3,
    this.pulseDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _PulseIconState createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.pulseSize, widget.pulseSize),
      painter: _PulseIconPainter(
        animation: _animationController,
        pulseColor: widget.pulseColor,
        innerSize: widget.innerSize,
        pulseCount: widget.pulseCount,
      ),
      child: SizedBox(
        width: widget.pulseSize,
        height: widget.pulseSize,
        child: Center(
          child: Container(
            width: widget.innerSize,
            height: widget.innerSize,
            decoration: BoxDecoration(
              color: widget.pulseColor.withOpacity(0.5), // Inner circle color
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _PulseIconPainter extends CustomPainter {
  final Animation<double> animation;
  final Color pulseColor;
  final double innerSize;
  final int pulseCount;

  _PulseIconPainter({
    required this.animation,
    required this.pulseColor,
    required this.innerSize,
    required this.pulseCount,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.clipRect(rect); // Clip to ensure pulses don't draw outside bounds

    final double center = size.width / 2;
    final double maxRadius = size.width / 2;
    final double innerRadius = innerSize / 2;

    for (int i = 0; i < pulseCount; i++) {
      // Calculate the progress for this specific pulse wave
      // Each wave is offset slightly in the animation
      final double waveProgress = (animation.value + (i / pulseCount)) % 1.0;

      final double radius =
          innerRadius + (maxRadius - innerRadius) * waveProgress;
      // Opacity decreases as the wave expands
      final double opacity = 1.0 - waveProgress;

      if (radius > innerRadius && opacity > 0) {
        paint.color = pulseColor.withOpacity(opacity * 0.7); // Apply opacity
        canvas.drawCircle(Offset(center, center), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PulseIconPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.pulseColor != pulseColor ||
        oldDelegate.innerSize != innerSize ||
        oldDelegate.pulseCount != pulseCount;
  }
}
