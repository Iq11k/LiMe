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
  });

  final double borderRadius;
  final double sigmaX;
  final double sigmaY;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

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
                  colors: [
                    Colors.white.withAlpha(160),
                    Colors.white.withAlpha(100),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withAlpha(100),
                  width: 2,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
