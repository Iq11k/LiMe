import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.borderRadius = 20,
    this.sigmaX = 14,
    this.sigmaY = 14,
    this.selectedItemColor = Colors.black,
    this.unselectedItemColor,
    this.padding = const EdgeInsets.only(top: 8),
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  final double borderRadius;
  final double sigmaX;
  final double sigmaY;

  final Color selectedItemColor;
  final Color? unselectedItemColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final Color unselected =
        unselectedItemColor ?? selectedItemColor.withOpacity(0.55);

    final theme = Theme.of(context);
    final transparentTheme = theme.copyWith(
      canvasColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      // Material 3 often uses surface + surfaceTint for backgrounds.
      colorScheme: theme.colorScheme.copyWith(surface: Colors.transparent),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.06),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.22), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: padding,
              child: Theme(
                data: transparentTheme,
                child: Material(
                  // Prevent any default white Material behind the bar.
                  color: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: onTap,
                    items: items,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: selectedItemColor,
                    unselectedItemColor: unselected,
                    showUnselectedLabels: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
