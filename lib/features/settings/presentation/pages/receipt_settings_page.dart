import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../bloc/org_settings_bloc.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    context.read<OrgSettingsBloc>().add(const OrgSettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrgSettingsBloc, OrgSettingsState>(
          listener: (_, state) {
            if (state.status == OrgSettingsStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            } else if (state.status == OrgSettingsStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final org = state.settings;
            if (org == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                PageHeader(
                  title: 'Receipt settings',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _nav.pop,
                  ),
                  trailing: TextButton(
                    onPressed: state.dirty
                        ? () => context
                            .read<OrgSettingsBloc>()
                            .add(const OrgSettingsSaveRequested())
                        : null,
                    child: const Text('Save'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'Branding'),
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'AK',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Organization logo',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  Text('PNG / SVG · max 1 MB',
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Upload'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Details'),
                      AppCard(
                        child: Column(
                          children: [
                            AppTextField(
                              label: 'Organization name',
                              initialValue: org.name,
                              onChanged: (v) => context
                                  .read<OrgSettingsBloc>()
                                  .add(OrgSettingsFieldChanged(name: v)),
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Address',
                              initialValue: org.address,
                              maxLines: 2,
                              onChanged: (v) => context
                                  .read<OrgSettingsBloc>()
                                  .add(OrgSettingsFieldChanged(address: v)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Contact',
                                    initialValue: org.contact,
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) => context
                                        .read<OrgSettingsBloc>()
                                        .add(OrgSettingsFieldChanged(
                                            contact: v)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    label: 'NTN (opt.)',
                                    initialValue: org.ntn ?? '',
                                    onChanged: (v) => context
                                        .read<OrgSettingsBloc>()
                                        .add(OrgSettingsFieldChanged(ntn: v)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Receipt template'),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  AppTextField(
                                    label: 'Footer text (Urdu)',
                                    initialValue: org.footerUrdu,
                                    maxLines: 2,
                                    onChanged: (v) => context
                                        .read<OrgSettingsBloc>()
                                        .add(OrgSettingsFieldChanged(
                                            footerUrdu: v)),
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    label: 'Footer text (English)',
                                    initialValue: org.footerEnglish,
                                    maxLines: 2,
                                    onChanged: (v) => context
                                        .read<OrgSettingsBloc>()
                                        .add(OrgSettingsFieldChanged(
                                            footerEnglish: v)),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: scheme.outlineVariant, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Watermark on PDF',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                        Text('Faint logo behind receipt body',
                                            style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: org.watermarkOnPdf,
                                    onChanged: (v) => context
                                        .read<OrgSettingsBloc>()
                                        .add(OrgSettingsWatermarkToggled(v)),
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
              ],
            );
          },
        ),
      ),
    );
  }
}
