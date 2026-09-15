import 'package:flutter/material.dart';

enum AppNavTab { home, animals, receipts, reports, more }

class AppBottomNav extends StatelessWidget {
  final AppNavTab current;
  final ValueChanged<AppNavTab> onTap;
  const AppBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      (AppNavTab.home, Icons.home_outlined, Icons.home, 'Home'),
      (AppNavTab.animals, Icons.pets_outlined, Icons.pets, 'Animals'),
      (AppNavTab.receipts, Icons.receipt_long_outlined, Icons.receipt_long, 'Receipts'),
      (AppNavTab.reports, Icons.bar_chart_outlined, Icons.bar_chart, 'Reports'),
      (AppNavTab.more, Icons.settings_outlined, Icons.settings, 'Settings'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (tab, iconOff, iconOn, label) in items)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(tab),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        current == tab ? iconOn : iconOff,
                        size: 22,
                        color: current == tab
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: current == tab
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
