import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../bloc/reports_bloc.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _nav = NavigationService();
  String _dayFilter = 'All days';

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const ReportsLoadRequested());
  }

  void _onTabTap(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.home:
        _nav.pushNamedAndRemoveUntil(RouteNames.dashboard);
      case AppNavTab.animals:
        _nav.pushReplacementNamed(RouteNames.animals);
      case AppNavTab.receipts:
        _nav.pushReplacementNamed(RouteNames.receipts);
      case AppNavTab.reports:
        break;
      case AppNavTab.more:
        _nav.pushReplacementNamed(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            final s = state.summary;
            return ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                PageHeader(
                  large: true,
                  title: 'Reports',
                  subtitle: 'Live snapshot of the season',
                  leading: Icon(Icons.trending_up,
                      color: scheme.onSurfaceVariant),
                  trailing: IconButton(
                    icon: Icon(Icons.download_outlined,
                        color: scheme.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final f in [
                          'All days',
                          'Day 1',
                          'Day 2',
                          'Day 3'
                        ]) ...[
                          InkWell(
                            onTap: () => setState(() => _dayFilter = f),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _dayFilter == f
                                    ? scheme.inverseSurface
                                    : scheme.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: _dayFilter == f
                                    ? null
                                    : Border.all(color: scheme.outlineVariant),
                              ),
                              child: Text(f,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: _dayFilter == f
                                        ? scheme.onInverseSurface
                                        : scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (s == null)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Total income',
                                value: Formatters.compactRupees(s.income),
                                sub: '${s.bookings} bookings',
                                accent: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatCard(
                                label: 'Bookings',
                                value: '${s.bookings}',
                                sub: '${s.customers} customers',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SectionHeader(title: 'Animal totals'),
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (int i = 0; i < s.animalTotals.length; i++) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: scheme.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          s.animalTotals[i].label.startsWith('Gaay')
                                              ? Icons.pets
                                              : Icons.cruelty_free,
                                          size: 18,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          s.animalTotals[i].label,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                      Text(
                                        '${s.animalTotals[i].count}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < s.animalTotals.length - 1)
                                  Divider(
                                    height: 1,
                                    color: scheme.outlineVariant,
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SectionHeader(
                          title: 'Quick reports',
                          action: TextButton(
                            onPressed: () =>
                                _nav.pushNamed(RouteNames.incomeExpense),
                            child: const Text('Open all →'),
                          ),
                        ),
                        for (final q in [
                          (
                            'Income vs Expense',
                            'Day-wise + animal type',
                            Icons.trending_up,
                            RouteNames.incomeExpense,
                          ),
                          (
                            'Hissedar list',
                            'Export all customers (CSV)',
                            Icons.person_outline,
                            null,
                          ),
                          (
                            'Cow allocation',
                            'Per-janwar breakdown',
                            Icons.pets,
                            RouteNames.animals,
                          ),
                          (
                            'Day-wise receipts',
                            'Filter by day · export PDF',
                            Icons.receipt_long_outlined,
                            RouteNames.receipts,
                          ),
                        ]) ...[
                          AppCard(
                            padding: const EdgeInsets.all(12),
                            onTap: q.$4 == null
                                ? null
                                : () => _nav.pushNamed(q.$4!),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(q.$3,
                                      size: 18, color: scheme.onSurfaceVariant),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(q.$1,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600)),
                                      Text(q.$2,
                                          style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: scheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar:
          AppBottomNav(current: AppNavTab.reports, onTap: _onTabTap),
    );
  }
}
