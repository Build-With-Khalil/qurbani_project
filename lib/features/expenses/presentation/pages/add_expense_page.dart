import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expenses_bloc.dart';

class AddExpensePage extends StatefulWidget {
  final String? editId;
  const AddExpensePage({super.key, this.editId});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _nav = NavigationService();
  final _amount = TextEditingController(text: '0');
  final _description = TextEditingController();
  final _link = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.qasai;
  DateTime _date = DateTime.now();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final id = widget.editId;
    if (id != null) {
      final existing = context
          .read<ExpensesBloc>()
          .state
          .all
          .where((e) => e.id == id)
          .firstOrNull;
      if (existing != null) {
        _amount.text = '${existing.amount.toInt()}';
        _description.text = existing.description;
        _link.text = existing.linkedAnimalTag ?? '';
        _category = existing.category;
        _date = existing.date;
      }
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _link.dispose();
    super.dispose();
  }

  void _save() {
    final value = num.tryParse(_amount.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid amount enter karein.')),
      );
      return;
    }
    final expense = Expense(
      id: widget.editId ?? _uuid.v4(),
      category: _category,
      amount: value,
      description: _description.text.trim(),
      linkedAnimalTag:
          _link.text.trim().isEmpty ? null : _link.text.trim(),
      date: _date,
    );
    context.read<ExpensesBloc>().add(ExpenseSaved(expense));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<ExpensesBloc, ExpensesState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (_, state) {
            if (state.status == ExpensesStatus.saved) {
              _nav.pop();
            } else if (state.status == ExpensesStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PageHeader(
                title: widget.editId == null ? 'Add expense' : 'Edit expense',
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _nav.pop,
                ),
                trailing: TextButton(onPressed: _save, child: const Text('Save')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Text('AMOUNT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('Rs ',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      color: scheme.onSurfaceVariant)),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.8,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    filled: false,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'Category'),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.05,
                      children: [
                        for (final c in ExpenseCategory.values)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _category = c),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _category == c
                                    ? scheme.primaryContainer
                                        .withValues(alpha: 0.3)
                                    : scheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _category == c
                                      ? scheme.primary
                                      : scheme.outlineVariant,
                                  width: _category == c ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(c.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(c.label,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _category == c
                                            ? scheme.primary
                                            : scheme.onSurface,
                                      )),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'Details'),
                    AppCard(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => _date = picked);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 18,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Date',
                                            style: theme.textTheme.labelSmall),
                                        Text(
                                          '${_date.day}/${_date.month}/${_date.year}',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: scheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Description',
                            controller: _description,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Link to animal (optional)',
                            controller: _link,
                            hint: 'e.g. COW-08',
                            prefixIcon: Icons.label_outline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
