import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/receipt.dart';
import '../bloc/receipts_bloc.dart';

class ReceiptsListPage extends StatefulWidget {
  const ReceiptsListPage({super.key});

  @override
  State<ReceiptsListPage> createState() => _ReceiptsListPageState();
}

class _ReceiptsListPageState extends State<ReceiptsListPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<ReceiptsBloc>().add(const ReceiptsLoadRequested());
  }

  void _onTabTap(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.home:
        _nav.pushNamedAndRemoveUntil(RouteNames.dashboard);
      case AppNavTab.animals:
        _nav.pushReplacementNamed(RouteNames.animals);
      case AppNavTab.receipts:
        break;
      case AppNavTab.reports:
        _nav.pushReplacementNamed(RouteNames.reports);
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
        child: BlocBuilder<ReceiptsBloc, ReceiptsState>(
          builder: (context, state) {
            final total = state.all.fold<num>(0, (a, r) => a + r.amount);
            return Column(
              children: [
                PageHeader(
                  large: true,
                  title: 'Receipts',
                  subtitle:
                      '${state.all.length} receipts · ${Formatters.compactRupees(total)} total',
                  leading: Icon(Icons.receipt_long_outlined,
                      color: scheme.onSurfaceVariant),
                  trailing: IconButton(
                    icon: Icon(Icons.download_outlined,
                        color: scheme.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  color: scheme.surface,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 38,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                size: 18, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search receipt no., name, phone…',
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  filled: false,
                                ),
                                style: theme.textTheme.bodyMedium,
                                onChanged: (v) => context
                                    .read<ReceiptsBloc>()
                                    .add(ReceiptsSearchChanged(v)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final f in [
                              'All days',
                              'Day 1',
                              'Day 2',
                              'Day 3',
                              'Gaay',
                              'Bakra'
                            ]) ...[
                              _FilterChip(
                                label: f,
                                selected: state.filter == f,
                                onTap: () => context
                                    .read<ReceiptsBloc>()
                                    .add(ReceiptsFilterChanged(f)),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.status == ReceiptsStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.visible.isEmpty
                          ? Center(
                              child: Text('No receipts',
                                  style: theme.textTheme.bodyMedium),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final r = state.visible[i];
                                return _ReceiptCard(
                                  receipt: r,
                                  onTap: () => _nav.pushNamed(
                                    RouteNames.receiptDetail,
                                    arguments: r.id,
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar:
          AppBottomNav(current: AppNavTab.receipts, onTap: _onTabTap),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.inverseSurface : scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected
                    ? scheme.onInverseSurface
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;
  const _ReceiptCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initials = receipt.customerName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first)
        .join();
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Text(initials,
                style: TextStyle(color: scheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        receipt.customerName,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('  · ${receipt.id}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                Text(
                  '${receipt.typeDesc} · ${_when(receipt.createdAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            'Rs ${Formatters.number(receipt.amount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _when(DateTime d) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(d);
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today · $time';
    }
    final y = now.subtract(const Duration(days: 1));
    if (d.year == y.year && d.month == y.month && d.day == y.day) {
      return 'Yesterday · $time';
    }
    return '${DateFormat('d MMM').format(d)} · $time';
  }
}
