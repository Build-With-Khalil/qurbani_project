import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../settings/domain/entities/rate.dart';
import '../bloc/booking_bloc.dart';

class ReviewBookingPage extends StatelessWidget {
  const ReviewBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = NavigationService();
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<BookingBloc, BookingFlowState>(
          listener: (context, state) {
            if (state.status == BookingStatus.success &&
                state.receiptId != null) {
              nav.pushReplacementNamed(
                RouteNames.receiptDetail,
                arguments: state.receiptId,
              );
              context.read<BookingBloc>().add(const BookingReset());
            } else if (state.status == BookingStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final draft = state.draft;
            final customer = draft.customer;
            return Column(
              children: [
                PageHeader(
                  title: 'Review & confirm',
                  subtitle: 'Step 4 of 4',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: nav.pop,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SectionHeader(title: 'Hissedar'),
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                customer?.initials ?? '?',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer?.name ?? '—',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  Text(
                                    '${customer?.mobile ?? ''}${customer?.address != null ? ' · ${customer!.address}' : ''}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 18, color: scheme.onSurfaceVariant),
                              onPressed: nav.pop,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SectionHeader(title: 'Booking'),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _Row(
                              label: 'Janwar',
                              value:
                                  '${draft.type.label}${draft.type == AnimalType.gaay && draft.cowTag != null ? ' · ${draft.cowTag}' : ''}',
                            ),
                            _Divider(),
                            _Row(
                              label: 'Qurbani din',
                              value: 'Day ${draft.day}',
                            ),
                            _Divider(),
                            if (draft.type == AnimalType.gaay) ...[
                              _Row(
                                label: 'Hissay',
                                value: '${draft.hissaCount} of 7',
                              ),
                              _Divider(),
                              _Row(
                                label: 'Rate per hissa',
                                value: 'Rs ${Formatters.number(draft.rate)}',
                              ),
                            ] else ...[
                              _Row(
                                label: 'Quantity',
                                value: '${draft.quantity} janwar',
                              ),
                              _Divider(),
                              _Row(
                                label: 'Rate per janwar',
                                value: 'Rs ${Formatters.number(draft.rate)}',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.inverseSurface,
                          borderRadius: BorderRadius.circular(14),
                          gradient: RadialGradient(
                            center: const Alignment(1, -0.6),
                            radius: 1.2,
                            colors: [
                              scheme.primary.withValues(alpha: 0.55),
                              scheme.inverseSurface,
                            ],
                            stops: const [0, 0.7],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('TOTAL AMOUNT',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onInverseSurface
                                          .withValues(alpha: 0.7),
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const Spacer(),
                                const AppBadge(
                                    label: 'Cash / Bank', tone: BadgeTone.ok),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('Rs ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onInverseSurface
                                          .withValues(alpha: 0.7),
                                    )),
                                Text(
                                  Formatters.number(draft.total),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: scheme.onInverseSurface,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Receipt # will be assigned on confirm',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onInverseSurface
                                      .withValues(alpha: 0.7),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(top: BorderSide(color: scheme.outlineVariant)),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                        onPressed: () =>
                            nav.pushNamedAndRemoveUntil(RouteNames.newBooking),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Confirm & generate receipt',
                          icon: Icons.check,
                          loading: state.status == BookingStatus.submitting,
                          onPressed: () => context
                              .read<BookingBloc>()
                              .add(const BookingConfirmRequested()),
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
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant);
}
