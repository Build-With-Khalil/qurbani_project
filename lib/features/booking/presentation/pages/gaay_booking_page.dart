import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/hissa_bars.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/booking_bloc.dart';

class GaayBookingPage extends StatelessWidget {
  const GaayBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = NavigationService();
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BookingBloc, BookingFlowState>(
          builder: (context, state) {
            final filled = 4; // placeholder demo state if no real cow
            final vacant = 7 - filled;
            final max = vacant;
            final count = state.draft.hissaCount.clamp(1, max);
            final slots = <HissaSlot>[
              for (int i = 0; i < filled; i++) HissaSlot.filled('Existing #${i + 1}'),
              for (int i = 0; i < vacant; i++)
                if (i < count)
                  HissaSlot.pending(state.draft.customer?.name ?? 'You · pending')
                else
                  const HissaSlot.vacant(),
            ];
            return Column(
              children: [
                PageHeader(
                  title: 'Select hissay',
                  subtitle: 'Step 2 · Gaay',
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
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.pets, color: scheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        state.draft.cowTag ?? 'New cow',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 6),
                                      AppBadge(
                                        label: state.draft.cowTag == null
                                            ? 'New'
                                            : 'Partial · $filled/7',
                                        tone: state.draft.cowTag == null
                                            ? BadgeTone.ok
                                            : BadgeTone.warn,
                                      ),
                                    ],
                                  ),
                                  Text(
                                      '${state.draft.cowTag == null ? 7 : vacant} hissay vacant',
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              onPressed: () {
                                context
                                    .read<BookingBloc>()
                                    .add(const BookingCowChanged(null));
                              },
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text('7 HISSAY',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurfaceVariant,
                                    )),
                                const Spacer(),
                                Text(
                                  '$filled filled · $count selected',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            HissaBars(
                                slots: slots, amountPerHissa: state.draft.rate),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('HOW MANY HISSAY?',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _Btn(
                                  icon: Icons.remove,
                                  onTap: count > 1
                                      ? () => context
                                          .read<BookingBloc>()
                                          .add(BookingHissaCountChanged(
                                              count - 1))
                                      : null,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('$count',
                                          style: theme.textTheme.displaySmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -1,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          )),
                                      Text('of $max vacant',
                                          style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                _Btn(
                                  icon: Icons.add,
                                  primary: true,
                                  onTap: count < max
                                      ? () => context
                                          .read<BookingBloc>()
                                          .add(BookingHissaCountChanged(
                                              count + 1))
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                for (int n = 1; n <= max; n++) ...[
                                  if (n > 1) const SizedBox(width: 6),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => context
                                          .read<BookingBloc>()
                                          .add(BookingHissaCountChanged(n)),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: count == n
                                              ? scheme.primaryContainer
                                                  .withValues(alpha: 0.5)
                                              : scheme.surface,
                                          border: Border.all(
                                            color: count == n
                                                ? scheme.primary
                                                : scheme.outlineVariant,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text('$n',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: count == n
                                                  ? scheme.primary
                                                  : scheme.onSurface,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _BottomSummary(
                  rate: state.draft.rate,
                  count: count,
                  onContinue: () => nav.pushNamed(
                    RouteNames.customer,
                    arguments: context.read<BookingBloc>(),
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

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;
  const _Btn({required this.icon, this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: primary
          ? (onTap == null
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.primary)
          : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: primary
                ? null
                : Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(
            icon,
            color: primary ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _BottomSummary extends StatelessWidget {
  final int rate;
  final int count;
  final VoidCallback onContinue;
  const _BottomSummary({
    required this.rate,
    required this.count,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count × Rs ${Formatters.number(rate)}',
                  style: theme.textTheme.bodySmall),
              Text(
                'Rs ${Formatters.number(count * rate)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Continue →',
            fullWidth: false,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
