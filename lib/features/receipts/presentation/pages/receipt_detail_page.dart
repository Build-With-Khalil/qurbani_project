import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/segment_control.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/repositories/receipts_repository.dart';
import '../bloc/receipts_bloc.dart';

enum _ReceiptView { person, janwar }

class ReceiptDetailPage extends StatefulWidget {
  final String receiptId;
  const ReceiptDetailPage({super.key, required this.receiptId});

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  final _nav = NavigationService();
  _ReceiptView _view = _ReceiptView.person;

  @override
  void initState() {
    super.initState();
    context.read<ReceiptsBloc>().add(ReceiptDetailRequested(widget.receiptId));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.inverseSurface,
      body: SafeArea(
        child: BlocBuilder<ReceiptsBloc, ReceiptsState>(
          builder: (context, state) {
            final bundle = state.selected;
            if (bundle == null || bundle.receipt.id != widget.receiptId) {
              return const Center(child: CircularProgressIndicator());
            }
            final isGaay = bundle.receipt.animalType == AnimalType.gaay;
            return Column(
              children: [
                Container(
                  color: scheme.surface,
                  child: PageHeader(
                    title: 'Receipt',
                    subtitle:
                        '${bundle.receipt.id} · ${DateFormat('HH:mm').format(bundle.receipt.createdAt)}',
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _nav.pop,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                    ),
                  ),
                ),
                if (isGaay)
                  Container(
                    color: scheme.surface,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SegmentControl<_ReceiptView>(
                      selected: _view,
                      options: const [
                        SegmentOption(_ReceiptView.person, 'Per Person'),
                        SegmentOption(_ReceiptView.janwar, 'Per Janwar (Gaay)'),
                      ],
                      onChanged: (v) => setState(() => _view = v),
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF3F3F46),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: _ReceiptCanvas(
                            bundle: bundle,
                            view: _view,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: scheme.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.print_outlined, size: 18),
                          label: const Text('Print'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share via WhatsApp'),
                          onPressed: () {},
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

class _ReceiptCanvas extends StatelessWidget {
  final ReceiptBundle bundle;
  final _ReceiptView view;
  const _ReceiptCanvas({required this.bundle, required this.view});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final r = bundle.receipt;
    final org = bundle.org;
    final isGaay = r.animalType == AnimalType.gaay;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(blurRadius: 32, color: Colors.black54),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Stack(
        children: [
          if (org.watermarkOnPdf)
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(Icons.pets, size: 200, color: scheme.primary),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: scheme.primary, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('AK',
                          style: TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(org.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                          Text('${org.address} · ${org.contact}',
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Receipt no.',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                      Text(r.id,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: scheme.primary)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Date / Day',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                      Text(
                        '${DateFormat('d MMM yyyy').format(r.createdAt)} · Day ${r.day}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HISSEDAR',
                        style: TextStyle(fontSize: 9, color: Colors.black54)),
                    Text(r.customerName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    if (r.customerPhone != null || r.customerAddress != null)
                      Text(
                          '${r.customerPhone ?? ''}${r.customerAddress != null ? ' · ${r.customerAddress}' : ''}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 6,
                      child: Text('DESCRIPTION',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('QTY',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('AMOUNT',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                    ),
                  ],
                ),
              ),
              if (isGaay && view == _ReceiptView.janwar &&
                  bundle.animal != null) ...[
                for (int i = 0; i < bundle.animal!.hissay.length; i++)
                  _LineRow(
                    label: 'Hissa ${i + 1} · ${bundle.animal!.hissay[i].name}',
                    qty: '1',
                    amount: Formatters.number(bundle.animal!.hissay[i].amount),
                  ),
              ] else ...[
                _LineRow(
                  label: '${r.animalType.label} ${isGaay ? 'hissa · ${r.animalTag}' : '· ${r.animalTag}'}',
                  qty: '${r.hissaCount ?? r.quantity ?? 1}',
                  amount: Formatters.number(r.amount),
                  sub:
                      'Day ${r.day} · Rs ${Formatters.number(r.rate)} / ${isGaay ? "hissa" : "janwar"}',
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Total',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      'Rs ${Formatters.number(_displayedTotal(bundle))}',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: scheme.outline,
                        style: BorderStyle.solid),
                  ),
                ),
                child: Text(
                  org.footerUrdu,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  num _displayedTotal(ReceiptBundle bundle) {
    if (bundle.receipt.animalType == AnimalType.gaay &&
        view == _ReceiptView.janwar &&
        bundle.animal != null) {
      return bundle.animal!.hissay.fold<num>(0, (a, h) => a + h.amount);
    }
    return bundle.receipt.amount;
  }
}

class _LineRow extends StatelessWidget {
  final String label;
  final String? sub;
  final String qty;
  final String amount;
  const _LineRow({
    required this.label,
    this.sub,
    required this.qty,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                if (sub != null)
                  Text(sub!,
                      style: const TextStyle(
                          fontSize: 9, color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(qty,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            flex: 3,
            child: Text(amount,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
