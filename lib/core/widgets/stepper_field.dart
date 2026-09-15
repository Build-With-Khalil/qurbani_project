import 'package:flutter/material.dart';

class StepperField extends StatelessWidget {
  final int value;
  final int min;
  final int? max;
  final String? caption;
  final ValueChanged<int> onChanged;

  const StepperField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final canDec = value > min;
    final canInc = max == null || value < max!;
    return Row(
      children: [
        _StepBtn(
          icon: Icons.remove,
          enabled: canDec,
          onTap: canDec ? () => onChanged(value - 1) : null,
          color: scheme.surface,
          fg: scheme.onSurface,
          border: scheme.outlineVariant,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '$value',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (caption != null)
                Text(caption!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          enabled: canInc,
          onTap: canInc ? () => onChanged(value + 1) : null,
          color: scheme.primary,
          fg: scheme.onPrimary,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final Color color;
  final Color fg;
  final Color? border;
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.color,
    required this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border != null
                ? Border.all(color: border!)
                : null,
          ),
          child: Icon(icon, color: fg, size: 22),
        ),
      ),
    );
  }
}
