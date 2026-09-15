import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/animals_bloc.dart';

class CowDetailPage extends StatefulWidget {
  final String tag;
  const CowDetailPage({super.key, required this.tag});

  @override
  State<CowDetailPage> createState() => _CowDetailPageState();
}

class _CowDetailPageState extends State<CowDetailPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<AnimalsBloc>().add(AnimalsCowSelected(widget.tag));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AnimalsBloc, AnimalsState>(
          builder: (context, state) {
            final cow = state.selected;
            if (cow == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final totalCollected = cow.hissay.fold<num>(0, (a, h) => a + h.amount);
            final totalTarget = cow.rate * 7;
            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                PageHeader(
                  title: cow.tag,
                  subtitle:
                      '${cow.isComplete ? "Complete" : cow.isEmpty ? "Empty" : "Partial"} · ${cow.filled} of 7 hissay filled',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _nav.pop,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child:
                                  Icon(Icons.pets, color: scheme.primary, size: 34),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _Stat(label: 'Weight', value: cow.weight),
                                      const SizedBox(width: 14),
                                      _Stat(label: 'Day', value: 'Day ${cow.day}'),
                                      const SizedBox(width: 14),
                                      _Stat(
                                        label: 'Rate',
                                        value: 'Rs ${Formatters.number(cow.rate)}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: cow.filled / 7,
                                    minHeight: 6,
                                    backgroundColor: scheme.outlineVariant,
                                    color: scheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SectionHeader(
                        title: '7 Hissay',
                        action: TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add hissedar'),
                          onPressed: () =>
                              _nav.pushNamed(RouteNames.newBooking),
                        ),
                      ),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < 7; i++) ...[
                              _HissaRow(
                                index: i + 1,
                                slot: i < cow.hissay.length ? cow.hissay[i] : null,
                                onAdd: () => _nav.pushNamed(RouteNames.newBooking),
                                onReceipt: i < cow.hissay.length
                                    ? () => _nav.pushNamed(
                                          RouteNames.receiptDetail,
                                          arguments: cow.hissay[i].receiptId,
                                        )
                                    : null,
                              ),
                              if (i < 6)
                                Divider(
                                    height: 1, color: scheme.outlineVariant),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        child: Row(
                          children: [
                            Text('Collected so far',
                                style: theme.textTheme.bodyMedium),
                            const Spacer(),
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                                children: [
                                  TextSpan(
                                      text:
                                          'Rs ${Formatters.number(totalCollected)} '),
                                  TextSpan(
                                    text: '/ Rs ${Formatters.number(totalTarget)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _HissaRow extends StatelessWidget {
  final int index;
  final dynamic slot; // HissaSlotEntity or null
  final VoidCallback onAdd;
  final VoidCallback? onReceipt;
  const _HissaRow({
    required this.index,
    required this.slot,
    required this.onAdd,
    this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isVacant = slot == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isVacant ? scheme.surfaceContainerHighest : scheme.primary,
              borderRadius: BorderRadius.circular(7),
              border: isVacant
                  ? Border.all(
                      color: scheme.outline,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                color: isVacant ? scheme.onSurfaceVariant : scheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVacant ? 'Vacant' : (slot.name as String),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle:
                        isVacant ? FontStyle.italic : FontStyle.normal,
                    color: isVacant
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isVacant)
                  Text(
                    'Rs ${Formatters.number(slot.amount as num)} · Receipt ${slot.receiptId}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (isVacant)
            OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('+ Add', style: TextStyle(fontSize: 12)),
            )
          else
            TextButton(
              onPressed: onReceipt,
              child: const Text('Receipt'),
            ),
        ],
      ),
    );
  }
}
