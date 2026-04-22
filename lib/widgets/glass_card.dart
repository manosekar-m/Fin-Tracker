import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.05,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultRadius = BorderRadius.circular(20);

    if (!isDark) {
      // Fallback for light mode: just a regular card
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius ?? defaultRadius,
          border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
        ),
        child: child,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? defaultRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((opacity * 255).toInt()),
              borderRadius: borderRadius ?? defaultRadius,
              border: Border.all(
                color: Colors.white.withAlpha((opacity * 255).toInt() * 2), // Slightly brighter border
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
