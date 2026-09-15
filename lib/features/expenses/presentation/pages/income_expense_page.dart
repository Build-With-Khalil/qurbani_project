import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';

class IncomeExpensePage extends StatefulWidget {
  const IncomeExpensePage({super.key});

  @override
  State<IncomeExpensePage> createState() => _IncomeExpensePageState();
}

class _IncomeExpensePageState extends State<IncomeExpensePage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const ReportsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            final s = state.summary;
            if (s == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                PageHeader(
                  title: 'Income vs Expense',
                  subtitle: 'Season summary',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _nav.pop,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Income',
                              value: Formatters.compactRupees(s.income),
                              sub: '${s.bookings} bookings',
                              accent: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              label: 'Expense',
                              value: Formatters.compactRupees(s.expense),
                              sub: '${s.expenseEntries} entries',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.inverseSurface,
                          borderRadius: BorderRadius.circular(14),
                          gradient: RadialGradient(
                            center: const Alignment(1, -0.5),
                            radius: 1.2,
                            colors: [
                              scheme.primary.withValues(alpha: 0.5),
                              scheme.inverseSurface,
                            ],
                            stops: const [0, 0.7],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NET SURPLUS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onInverseSurface
                                      .withValues(alpha: 0.7),
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w700,
                                )),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.rupees(s.income - s.expense),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scheme.onInverseSurface,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.income == 0
                                  ? '—'
                                  : '${((s.income - s.expense) / s.income * 100).toStringAsFixed(1)}% of income · disbursable to beneficiaries',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onInverseSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SectionHeader(title: 'Day-wise'),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 140,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (final d in s.dayBars)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _Bar(
                                                  height: _h(d.income, s.maxDayBar),
                                                  color: scheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                _Bar(
                                                  height: _h(
                                                      d.expense, s.maxDayBar),
                                                  color: scheme.outlineVariant,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text('Day ${d.day}',
                                              style: theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _Legend(color: scheme.primary, label: 'Income'),
                                const SizedBox(width: 16),
                                _Legend(
                                    color: scheme.outlineVariant,
                                    label: 'Expense'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SectionHeader(title: 'By animal type'),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < s.byType.length; i++) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(s.byType[i].label,
                                              style:
                                                  theme.textTheme.bodySmall),
                                        ),
                                        Text(
                                          Formatters.rupees(s.byType[i].amount),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: s.byType[i].fraction,
                                        minHeight: 5,
                                        backgroundColor: scheme.outlineVariant,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < s.byType.length - 1)
                                Divider(
                                    height: 1, color: scheme.outlineVariant),
                            ],
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

  double _h(num value, num max) =>
      max == 0 ? 0 : (value / max).clamp(0, 1) * 120;
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
