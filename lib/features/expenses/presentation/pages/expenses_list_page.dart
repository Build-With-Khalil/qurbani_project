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
import '../../domain/entities/expense.dart';
import '../bloc/expenses_bloc.dart';

class ExpensesListPage extends StatefulWidget {
  const ExpensesListPage({super.key});

  @override
  State<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<ExpensesBloc>().add(const ExpensesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ExpensesBloc, ExpensesState>(
          builder: (context, state) {
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    PageHeader(
                      large: true,
                      title: 'Expenses',
                      subtitle:
                          '${Formatters.compactRupees(state.total)} · ${state.all.length} entries',
                      leading: Icon(Icons.account_balance_wallet_outlined,
                          color: scheme.onSurfaceVariant),
                      trailing: IconButton(
                        icon: Icon(Icons.bar_chart,
                            color: scheme.onSurfaceVariant),
                        onPressed: () =>
                            _nav.pushNamed(RouteNames.incomeExpense),
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
                                  label: 'Janwar',
                                  value: Formatters.compactRupees(
                                      state.totalForCategories([
                                    ExpenseCategory.janwar
                                  ])),
                                  accent: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatCard(
                                  label: 'Operations',
                                  value: Formatters.compactRupees(
                                      state.totalForCategories([
                                    ExpenseCategory.qasai,
                                    ExpenseCategory.labour,
                                    ExpenseCategory.packing,
                                  ])),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StatCard(
                                  label: 'Logistics',
                                  value: Formatters.compactRupees(
                                      state.totalForCategories([
                                    ExpenseCategory.transport,
                                    ExpenseCategory.feed
                                  ])),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (state.all.isEmpty)
                            AppCard(
                              child: Text(
                                'No expenses yet. Add one with the + button.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          else
                            for (final g in state.groups) ...[
                              SectionHeader(title: g.dayLabel),
                              AppCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (int i = 0;
                                        i < g.items.length;
                                        i++) ...[
                                      _ExpenseRow(
                                        expense: g.items[i],
                                        onTap: () =>
                                            _nav.pushNamed(RouteNames.addExpense,
                                                arguments: g.items[i].id),
                                      ),
                                      if (i < g.items.length - 1)
                                        Divider(
                                          color: scheme.outlineVariant,
                                          height: 1,
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: FloatingActionButton(
                    onPressed: () => _nav.pushNamed(RouteNames.addExpense),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.more,
        onTap: (t) {
          switch (t) {
            case AppNavTab.home:
              _nav.pushNamedAndRemoveUntil(RouteNames.dashboard);
            case AppNavTab.animals:
              _nav.pushReplacementNamed(RouteNames.animals);
            case AppNavTab.receipts:
              _nav.pushReplacementNamed(RouteNames.receipts);
            case AppNavTab.reports:
              _nav.pushReplacementNamed(RouteNames.reports);
            case AppNavTab.more:
              _nav.pushReplacementNamed(RouteNames.settings);
          }
        },
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  const _ExpenseRow({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(expense.category.emoji,
                  style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category.label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    expense.description,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              'Rs ${Formatters.number(expense.amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
