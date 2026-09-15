import 'package:flutter/material.dart';

class HissaSlot {
  final String? name;
  final bool pending;
  const HissaSlot.vacant() : name = null, pending = false;
  const HissaSlot.filled(this.name) : pending = false;
  const HissaSlot.pending(this.name) : pending = true;

  bool get isVacant => name == null;
}

/// Inline 7-dot indicator (compact list/card use).
class HissaDots extends StatelessWidget {
  final int filled;
  final int total;
  final double size;
  const HissaDots({
    super.key,
    required this.filled,
    this.total = 7,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Container(
          margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isFilled ? scheme.primary : scheme.outlineVariant,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// Full vertical list of 7 hissay with names/amounts.
class HissaBars extends StatelessWidget {
  final List<HissaSlot> slots;
  final int amountPerHissa;
  const HissaBars({super.key, required this.slots, required this.amountPerHissa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        for (int i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _HissaRow(
            index: i + 1,
            slot: slots[i],
            amount: amountPerHissa,
            scheme: scheme,
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _HissaRow extends StatelessWidget {
  final int index;
  final HissaSlot slot;
  final int amount;
  final ColorScheme scheme;
  final ThemeData theme;
  const _HissaRow({
    required this.index,
    required this.slot,
    required this.amount,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isVacant = slot.isVacant;
    final isPending = slot.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isVacant
            ? scheme.surfaceContainerLow
            : isPending
                ? scheme.primaryContainer.withValues(alpha: 0.35)
                : scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPending
              ? scheme.primary
              : isVacant
                  ? scheme.outlineVariant
                  : scheme.outlineVariant,
          style: isVacant && !isPending ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isVacant && !isPending
                  ? scheme.surfaceContainerHighest
                  : scheme.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isVacant && !isPending
                    ? scheme.onSurfaceVariant
                    : scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVacant && !isPending ? 'Vacant' : (slot.name ?? ''),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isVacant && !isPending
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                    fontStyle:
                        isVacant && !isPending ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                if (!isVacant || isPending)
                  Text(
                    'Rs ${amount.toString()}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
