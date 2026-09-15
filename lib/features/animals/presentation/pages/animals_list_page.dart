import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hissa_bars.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/animal.dart';
import '../bloc/animals_bloc.dart';

class AnimalsListPage extends StatefulWidget {
  const AnimalsListPage({super.key});

  @override
  State<AnimalsListPage> createState() => _AnimalsListPageState();
}

class _AnimalsListPageState extends State<AnimalsListPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<AnimalsBloc>().add(const AnimalsLoadRequested());
  }

  void _onTabTap(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.home:
        _nav.pushNamedAndRemoveUntil(RouteNames.dashboard);
      case AppNavTab.animals:
        break;
      case AppNavTab.receipts:
        _nav.pushReplacementNamed(RouteNames.receipts);
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
        child: BlocBuilder<AnimalsBloc, AnimalsState>(
          builder: (context, state) {
            return Column(
              children: [
                PageHeader(
                  large: true,
                  title: 'Animals',
                  subtitle:
                      '${state.all.length} booked · ${state.all.where((a) => a.isPartial).length} partial cows',
                  leading: Icon(Icons.pets, color: scheme.onSurfaceVariant),
                  trailing: IconButton(
                    icon: Icon(Icons.filter_alt_outlined,
                        color: scheme.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      bottom: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                  child: SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final t in AnimalsTab.values) ...[
                          _TabChip(
                            label: _tabLabel(t),
                            count: _tabCount(state.all, t),
                            selected: state.tab == t,
                            onTap: () =>
                                context.read<AnimalsBloc>().add(AnimalsTabChanged(t)),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: state.status == AnimalsStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.visible.isEmpty
                          ? Center(
                              child: Text('No animals',
                                  style: theme.textTheme.bodyMedium),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final a = state.visible[i];
                                return _AnimalCard(
                                  animal: a,
                                  onTap: () => _nav.pushNamed(
                                    RouteNames.cowDetail,
                                    arguments: a.tag,
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
          AppBottomNav(current: AppNavTab.animals, onTap: _onTabTap),
    );
  }

  String _tabLabel(AnimalsTab t) => switch (t) {
        AnimalsTab.all => 'All',
        AnimalsTab.partial => 'Partial',
        AnimalsTab.complete => 'Complete',
        AnimalsTab.bakra => 'Bakra',
      };

  int _tabCount(List<Animal> all, AnimalsTab t) => switch (t) {
        AnimalsTab.all => all.length,
        AnimalsTab.partial => all.where((a) => a.isPartial).length,
        AnimalsTab.complete => all.where((a) => a.isComplete).length,
        AnimalsTab.bakra => all.where((a) => a.type != AnimalType.gaay).length,
      };
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.inverseSurface : scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? scheme.onInverseSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? scheme.onInverseSurface.withValues(alpha: 0.6)
                        : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  const _AnimalCard({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isCow = animal.type == AnimalType.gaay;
    final tone = animal.isComplete
        ? BadgeTone.ok
        : animal.isEmpty
            ? BadgeTone.neutral
            : BadgeTone.warn;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCow ? Icons.pets : Icons.cruelty_free,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(animal.tag,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    if (animal.weight.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('· ${animal.weight}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
                Text(
                  isCow
                      ? (animal.hissay.isEmpty
                          ? 'No bookings yet'
                          : animal.hissay
                              .take(2)
                              .map((h) => h.name)
                              .join(', '))
                      : '${animal.type.label} · Day ${animal.day}',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBadge(label: isCow ? '${animal.filled}/7' : '${animal.quantity}', tone: tone),
              if (isCow) ...[
                const SizedBox(height: 4),
                HissaDots(filled: animal.filled, size: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
