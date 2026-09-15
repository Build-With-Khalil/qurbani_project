import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.onTap,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(14);
    return Material(
      color: color ?? scheme.surface,
      borderRadius: radius is BorderRadius ? radius : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius is BorderRadius ? radius : BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? scheme.outlineVariant,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
