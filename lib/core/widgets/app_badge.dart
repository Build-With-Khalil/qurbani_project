import 'package:flutter/material.dart';

enum BadgeTone { neutral, accent, ok, warn, danger }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final IconData? icon;
  const AppBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      BadgeTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      BadgeTone.accent => (scheme.primaryContainer, scheme.onPrimaryContainer),
      BadgeTone.ok => (
          const Color(0x1A2F7A4F),
          const Color(0xFF1F5934),
        ),
      BadgeTone.warn => (
          const Color(0x1AB45309),
          const Color(0xFF92400E),
        ),
      BadgeTone.danger => (
          const Color(0x1AB91C1C),
          const Color(0xFFB91C1C),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
