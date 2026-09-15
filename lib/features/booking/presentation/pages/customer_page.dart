import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/customer.dart';
import '../bloc/booking_bloc.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _nav = NavigationService();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _cnic = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = context.read<BookingBloc>().state.draft.customer;
    if (c != null) {
      _name.text = c.name;
      _mobile.text = c.mobile;
      _address.text = c.address ?? '';
      _cnic.text = c.cnic ?? '';
      _note.text = c.note ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _address.dispose();
    _cnic.dispose();
    _note.dispose();
    super.dispose();
  }

  void _commitAndContinue() {
    final c = Customer(
      id: '',
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      cnic: _cnic.text.trim().isEmpty ? null : _cnic.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (c.name.isEmpty || c.mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name aur mobile required hain.')),
      );
      return;
    }
    context.read<BookingBloc>().add(BookingCustomerChanged(c));
    _nav.pushNamed(
      RouteNames.reviewBooking,
      arguments: context.read<BookingBloc>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Customer details',
              subtitle: 'Step 3 of 4',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _nav.pop,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText:
                                  'Search existing hissedar by name or phone…',
                              border: InputBorder.none,
                              isCollapsed: true,
                              filled: false,
                            ),
                            onChanged: (v) => context
                                .read<BookingBloc>()
                                .add(BookingCustomerQueryChanged(v)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<BookingBloc, BookingFlowState>(
                    builder: (_, state) {
                      if (state.customerResults.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final c in state.customerResults.take(4)) ...[
                              InkWell(
                                onTap: () {
                                  _name.text = c.name;
                                  _mobile.text = c.mobile;
                                  _address.text = c.address ?? '';
                                  _cnic.text = c.cnic ?? '';
                                  _note.text = c.note ?? '';
                                  context
                                      .read<BookingBloc>()
                                      .add(BookingCustomerChanged(c));
                                  context
                                      .read<BookingBloc>()
                                      .add(const BookingCustomerQueryChanged(''));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: scheme.primaryContainer,
                                        child: Text(c.initials,
                                            style: TextStyle(
                                                color:
                                                    scheme.onPrimaryContainer)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(c.name,
                                                style:
                                                    theme.textTheme.bodyMedium),
                                            Text(c.mobile,
                                                style:
                                                    theme.textTheme.bodySmall),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: scheme.onSurfaceVariant),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'OR NEW HISSEDAR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full name',
                          controller: _name,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Mobile',
                          controller: _mobile,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Address',
                          controller: _address,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'CNIC (optional)',
                          controller: _cnic,
                          hint: 'XXXXX-XXXXXXX-X',
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Note',
                          controller: _note,
                          hint: 'Niyat, special instructions…',
                          maxLines: 2,
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
                label: 'Review booking →',
                onPressed: _commitAndContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
