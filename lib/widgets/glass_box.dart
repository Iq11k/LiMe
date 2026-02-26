import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  const GlassBox({
    super.key,
    this.borderRadius = 10,
    this.sigmaX = 12,
    this.sigmaY = 12,
    this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.variant = 1,
  });

  final double borderRadius;
  final double sigmaX;
  final double sigmaY;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final int variant;

  List<Color> get _gradientColors {
    switch (variant) {
      case 2:
        return [Colors.black.withAlpha(140), Colors.black.withAlpha(90)];
      case 1:
      default:
        return [Colors.white.withAlpha(160), Colors.white.withAlpha(100)];
    }
  }

  Color get _borderColor {
    switch (variant) {
      case 2:
        return Colors.white.withAlpha(40);
      case 1:
      default:
        return Colors.white.withAlpha(100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradientColors,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: _borderColor, width: 2),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
