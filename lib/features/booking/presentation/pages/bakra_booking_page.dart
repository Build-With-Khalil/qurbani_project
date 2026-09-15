import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/domain/entities/rate.dart';
import '../bloc/booking_bloc.dart';

class BakraBookingPage extends StatelessWidget {
  const BakraBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = NavigationService();
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BookingBloc, BookingFlowState>(
          builder: (context, state) {
            final qty = state.draft.quantity;
            final rate = state.draft.rate;
            final total = qty * rate;
            return Column(
              children: [
                PageHeader(
                  title: 'How many janwar?',
                  subtitle: 'Step 2 · ${state.draft.type.label}',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: nav.pop,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.cruelty_free,
                                  color: scheme.primary, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text(
                                '${state.draft.type.label} · Day ${state.draft.day} rate',
                                style: theme.textTheme.bodySmall),
                            Text(
                                'Rs ${Formatters.number(rate)} per janwar',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _BigBtn(
                                  icon: Icons.remove,
                                  onTap: qty > 1
                                      ? () => context
                                          .read<BookingBloc>()
                                          .add(BookingQtyChanged(qty - 1))
                                      : null,
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '$qty',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -2,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                                _BigBtn(
                                  icon: Icons.add,
                                  primary: true,
                                  onTap: () => context
                                      .read<BookingBloc>()
                                      .add(BookingQtyChanged(qty + 1)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('JANWAR QUANTITY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  letterSpacing: 0.4,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                    '$qty × Rs ${Formatters.number(rate)}',
                                    style: theme.textTheme.bodyMedium),
                                const Spacer(),
                                Text('Rs ${Formatters.number(total)}',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                            Divider(color: scheme.outlineVariant),
                            Row(
                              children: [
                                Text('Total',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(
                                  'Rs ${Formatters.number(total)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: PrimaryButton(
                    label: 'Continue →',
                    onPressed: () => nav.pushNamed(
                      RouteNames.customer,
                      arguments: context.read<BookingBloc>(),
                    ),
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

class _BigBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;
  const _BigBtn({required this.icon, this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: primary
          ? (onTap == null
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.primary)
          : scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: primary
                ? null
                : Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(icon,
              size: 26,
              color: primary ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}
