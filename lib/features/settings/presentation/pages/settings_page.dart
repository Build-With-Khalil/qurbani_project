import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = NavigationService();
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final groups = <_SettingsGroup>[
      _SettingsGroup('Configuration', [
        _SettingsItem(
          icon: Icons.business_outlined,
          label: 'Receipt settings',
          sub: 'Logo, address, footer text',
          route: RouteNames.receiptSettings,
        ),
        _SettingsItem(
          icon: Icons.label_outline,
          label: 'Rate configuration',
          sub: '3 days × animal type',
          route: RouteNames.rates,
        ),
      ]),
      _SettingsGroup('Users & access', [
        _SettingsItem(
          icon: Icons.person_outline,
          label: 'Users & roles',
          sub: '4 admins, 11 operators',
        ),
        _SettingsItem(
          icon: Icons.shield_outlined,
          label: 'Permissions',
          sub: 'Who can edit rates / receipts',
        ),
      ]),
      _SettingsGroup('Data', [
        _SettingsItem(
          icon: Icons.cloud_outlined,
          label: 'Backup & export',
          sub: 'Last backup: yesterday 18:00',
          badge: const AppBadge(label: 'Due', tone: BadgeTone.warn),
        ),
        _SettingsItem(
          icon: Icons.download_outlined,
          label: 'Export all (Excel)',
          sub: 'Bookings, receipts, expenses',
        ),
      ]),
      _SettingsGroup('About', [
        _SettingsItem(
          icon: Icons.info_outline,
          label: 'App info',
          sub: 'v1.0.0 · build 142',
        ),
      ]),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            PageHeader(
              large: true,
              title: 'Settings',
              leading: Icon(Icons.settings_outlined,
                  color: scheme.onSurfaceVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (_, state) {
                      final user = state.user;
                      return AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user?.initials ?? 'AK',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? 'Guest',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    user == null
                                        ? '—'
                                        : '${user.role == UserRole.admin ? 'Admin' : 'Operator'} · ${user.branch ?? ''}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const AppBadge(label: 'Active', tone: BadgeTone.ok),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  for (final g in groups) ...[
                    SectionHeader(title: g.label),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (int i = 0; i < g.items.length; i++) ...[
                            _SettingsTile(
                              item: g.items[i],
                              onTap: g.items[i].route == null
                                  ? null
                                  : () => nav.pushNamed(g.items[i].route!),
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
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthSignOutRequested());
                        nav.pushNamedAndRemoveUntil(RouteNames.login);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup {
  final String label;
  final List<_SettingsItem> items;
  _SettingsGroup(this.label, this.items);
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String sub;
  final String? route;
  final Widget? badge;
  _SettingsItem({
    required this.icon,
    required this.label,
    required this.sub,
    this.route,
    this.badge,
  });
}

class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;
  final VoidCallback? onTap;
  const _SettingsTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 18, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.bodyMedium),
                  Text(item.sub, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (item.badge != null) ...[
              item.badge!,
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}
