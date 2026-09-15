import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hissa_bars.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  void _onTabTap(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.home:
        break;
      case AppNavTab.animals:
        _nav.pushNamed(RouteNames.animals);
      case AppNavTab.receipts:
        _nav.pushNamed(RouteNames.receipts);
      case AppNavTab.reports:
        _nav.pushNamed(RouteNames.reports);
      case AppNavTab.more:
        _nav.pushNamed(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final summary = state.summary;
            if (state.status == DashboardStatus.loading && summary == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (summary == null) {
              return const Center(child: Text('No data'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshRequested());
                await context
                    .read<DashboardBloc>()
                    .stream
                    .firstWhere((s) => s.status != DashboardStatus.loading);
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  PageHeader(
                    large: true,
                    title: 'Qurbani ${summary.seasonStart.year}',
                    subtitle:
                        'Day 1 · ${Formatters.dayLabel(summary.seasonStart)}',
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pets,
                          color: Colors.white, size: 20),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _nav.pushNamed(RouteNames.settings),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroBalance(summary: summary),
                        const SizedBox(height: 14),
                        _QuickActions(nav: _nav),
                        const SizedBox(height: 18),
                        SectionGroup(
                          title: "Today's collection",
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Today',
                                    value: Formatters.compactRupees(
                                        summary.todayIncome),
                                    sub: '${summary.todayReceipts} receipts',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Gaay',
                                    value:
                                        '${summary.gaayComplete}/${summary.gaayTotal}',
                                    sub: '${summary.gaayPartial} partial',
                                    accent: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Bakra',
                                    value: '${summary.bakraBooked}',
                                    sub: 'janwar',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SectionGroup(
                          title: 'Partial cows',
                          action: TextButton(
                            onPressed: () =>
                                _nav.pushNamed(RouteNames.animals),
                            child: const Text('See all →'),
                          ),
                          children: [
                            if (summary.partialCows.isEmpty)
                              AppCard(
                                child: Text(
                                  'No partial cows.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )
                            else
                              for (final cow in summary.partialCows)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _PartialCowCard(
                                    cow: cow,
                                    onTap: () => _nav.pushNamed(
                                      RouteNames.cowDetail,
                                      arguments: cow.tag,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.home,
        onTap: _onTabTap,
      ),
    );
  }
}

class _HeroBalance extends StatelessWidget {
  final DashboardSummary summary;
  const _HeroBalance({required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(18),
        gradient: RadialGradient(
          center: const Alignment(1.0, -0.5),
          radius: 1.2,
          colors: [
            scheme.primary.withValues(alpha: 0.6),
            scheme.inverseSurface,
          ],
          stops: const [0.0, 0.7],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NET BALANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onInverseSurface.withValues(alpha: 0.65),
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const AppBadge(label: 'Live', tone: BadgeTone.accent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rs ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onInverseSurface.withValues(alpha: 0.65),
                ),
              ),
              Text(
                Formatters.number(summary.netBalance),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: scheme.onInverseSurface.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeroStat(
                label: 'Income',
                value: Formatters.compactRupees(summary.income),
              ),
              const SizedBox(width: 18),
              _HeroStat(
                label: 'Expense',
                value: Formatters.compactRupees(summary.expense),
              ),
              const SizedBox(width: 18),
              _HeroStat(
                label: 'Bookings',
                value: '${summary.bookings}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onInverseSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final NavigationService nav;
  const _QuickActions({required this.nav});

  @override
  Widget build(BuildContext context) {
    final items = <_QuickAction>[
      _QuickAction(
        label: 'New booking',
        icon: Icons.add,
        route: RouteNames.newBooking,
        primary: true,
      ),
      _QuickAction(
        label: 'Add expense',
        icon: Icons.account_balance_wallet_outlined,
        route: RouteNames.addExpense,
      ),
      _QuickAction(
        label: 'Receipts',
        icon: Icons.receipt_long_outlined,
        route: RouteNames.receipts,
      ),
      _QuickAction(
        label: 'Animals',
        icon: Icons.pets,
        route: RouteNames.animals,
      ),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _QuickActionTile(
              item: items[i],
              onTap: () => nav.pushNamed(items[i].route),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final bool primary;
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
    this.primary = false,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction item;
  final VoidCallback onTap;
  const _QuickActionTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = item.primary ? scheme.primary : scheme.surface;
    final fg = item.primary ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: item.primary
                ? null
                : Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(item.icon, color: fg, size: 22),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool accent;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.sub,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final bg = accent ? scheme.primary : scheme.surface;
    final fg = accent ? scheme.onPrimary : scheme.onSurface;
    final muted = accent
        ? scheme.onPrimary.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: accent ? null : Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 2),
          Text(sub,
              style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}

class _PartialCowCard extends StatelessWidget {
  final PartialCowSummary cow;
  final VoidCallback onTap;
  const _PartialCowCard({required this.cow, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.pets, color: scheme.onSurfaceVariant, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(cow.tag,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    AppBadge(label: '${cow.filled}/7', tone: BadgeTone.warn),
                  ],
                ),
                if (cow.ownersPreview.isNotEmpty)
                  Text(
                    cow.ownersPreview,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          HissaDots(filled: cow.filled),
        ],
      ),
    );
  }
}
