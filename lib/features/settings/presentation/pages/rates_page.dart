import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/rate.dart';
import '../bloc/rates_bloc.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<RatesBloc>().add(const RatesLoadRequested());
  }

  Future<void> _editRate(
      BuildContext context, RateRow row, int day, int currentValue) async {
    final controller = TextEditingController(text: '$currentValue');
    final value = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${row.type.label} · Day $day',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: Theme.of(ctx).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(prefixText: 'Rs '),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final v = int.tryParse(controller.text);
                        Navigator.pop(ctx, v);
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) {
      if (!context.mounted) return;
      context
          .read<RatesBloc>()
          .add(RateCellEdited(type: row.type, day: day, value: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RatesBloc, RatesState>(
          listener: (_, state) {
            if (state.status == RatesStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rates saved')),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                PageHeader(
                  title: 'Rate configuration',
                  subtitle: '3 Qurbani days · independent rates',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _nav.pop,
                  ),
                  trailing: TextButton(
                    onPressed: state.dirty
                        ? () => context
                            .read<RatesBloc>()
                            .add(const RatesSaveRequested())
                        : null,
                    child: const Text('Save'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                border: Border(
                                  bottom: BorderSide(
                                      color: scheme.outlineVariant),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 14,
                                    child: Text('ANIMAL',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6)),
                                  ),
                                  for (final d in [1, 2, 3])
                                    Expanded(
                                      flex: 10,
                                      child: Text('DAY $d',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6)),
                                    ),
                                ],
                              ),
                            ),
                            for (int i = 0; i < state.rates.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: i < state.rates.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                              color: scheme.outlineVariant),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 14,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: scheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _iconFor(state.rates[i].type),
                                              size: 18,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              state.rates[i].type.label,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    for (final d in [1, 2, 3])
                                      Expanded(
                                        flex: 10,
                                        child: InkWell(
                                          onTap: () => _editRate(
                                            context,
                                            state.rates[i],
                                            d,
                                            state.rates[i].rateFor(d),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(
                                              Formatters.number(
                                                  state.rates[i].rateFor(d)),
                                              textAlign: TextAlign.right,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures()
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Day rates are independent — no fixed multiplier. Bookings auto-pick rate from selected day at receipt time.',
                                style: theme.textTheme.bodySmall,
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

  IconData _iconFor(AnimalType t) => switch (t) {
        AnimalType.gaay => Icons.pets,
        AnimalType.bakra => Icons.cruelty_free,
        AnimalType.dunba => Icons.cruelty_free,
        AnimalType.sheep => Icons.cruelty_free,
      };
}
