import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/domain/entities/rate.dart';
import '../bloc/booking_bloc.dart';

class AnimalTypePage extends StatefulWidget {
  const AnimalTypePage({super.key});

  @override
  State<AnimalTypePage> createState() => _AnimalTypePageState();
}

class _AnimalTypePageState extends State<AnimalTypePage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BookingBloc>();
    if (bloc.state.status == BookingStatus.initial ||
        bloc.state.rates.isEmpty) {
      bloc.add(const BookingInitRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BookingBloc, BookingFlowState>(
          builder: (context, state) {
            if (state.status == BookingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                PageHeader(
                  title: 'New booking',
                  subtitle: 'Step 1 of 4',
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        _nav.pushNamedAndRemoveUntil(RouteNames.dashboard),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _LabelText('JANWAR TYPE'),
                      const SizedBox(height: 10),
                      _typeGrid(context, state),
                      const SizedBox(height: 22),
                      _LabelText('QURBANI DIN'),
                      const SizedBox(height: 10),
                      _dayRow(context, state),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('APPLICABLE RATE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('Rs ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant)),
                                Text(
                                  Formatters.number(state.draft.rate),
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '· ${state.draft.type.label} ${state.draft.type.unitLabel}',
                                    style: theme.textTheme.bodySmall,
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
                    onPressed: () => _nav.pushNamed(
                      state.draft.type == AnimalType.gaay
                          ? RouteNames.gaayBooking
                          : RouteNames.bakraBooking,
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

  Widget _typeGrid(BuildContext context, BookingFlowState state) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final items = [
      (AnimalType.gaay, '1–7 hissay', Icons.pets),
      (AnimalType.bakra, 'Per janwar', Icons.cruelty_free),
      (AnimalType.dunba, 'Per janwar', Icons.cruelty_free_outlined),
      (AnimalType.sheep, 'Per janwar', Icons.cruelty_free_outlined),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        for (final (t, sub, ic) in items)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                context.read<BookingBloc>().add(BookingTypeChanged(t)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.draft.type == t
                    ? scheme.primaryContainer.withValues(alpha: 0.3)
                    : scheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: state.draft.type == t
                      ? scheme.primary
                      : scheme.outlineVariant,
                  width: state.draft.type == t ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(ic,
                      size: 26,
                      color: state.draft.type == t
                          ? scheme.primary
                          : scheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(t.label,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _dayRow(BuildContext context, BookingFlowState state) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final days = [
      (1, 'Day 1', 'Sat 28 Jun'),
      (2, 'Day 2', 'Sun 29 Jun'),
      (3, 'Day 3', 'Mon 30 Jun'),
    ];
    return Row(
      children: [
        for (int i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context
                  .read<BookingBloc>()
                  .add(BookingDayChanged(days[i].$1)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.draft.day == days[i].$1
                      ? scheme.primary
                      : scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.draft.day == days[i].$1
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      days[i].$2.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: state.draft.day == days[i].$1
                            ? scheme.onPrimary.withValues(alpha: 0.7)
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      days[i].$3,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: state.draft.day == days[i].$1
                            ? scheme.onPrimary
                            : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
    );
  }
}
