import 'package:flutter/material.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  const SegmentOption(this.value, this.label);
}

class SegmentControl<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final opt in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: opt.value == selected ? scheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: opt.value == selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      opt.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: opt.value == selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: opt.value == selected
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
