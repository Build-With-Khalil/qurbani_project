import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/segment_control.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController(text: '0301 234 5678');
  final _pin = TextEditingController(text: '0000');
  final _nav = NavigationService();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    bloc.add(AuthPhoneChanged(_phone.text));
    bloc.add(AuthPinChanged(_pin.text));
  }

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              _nav.pushNamedAndRemoveUntil(RouteNames.dashboard);
            } else if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.pets, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 22),
                  Text('Welcome back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      )),
                  const SizedBox(height: 6),
                  Text("Sign in to manage this season's Qurbani.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 28),
                  SegmentControl<UserRole>(
                    selected: state.role,
                    options: const [
                      SegmentOption(UserRole.admin, 'Admin'),
                      SegmentOption(UserRole.operator, 'Operator'),
                    ],
                    onChanged: (r) =>
                        context.read<AuthBloc>().add(AuthRoleChanged(r)),
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    label: 'Phone number',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthPhoneChanged(v)),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'PIN',
                    controller: _pin,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthPinChanged(v)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot PIN?'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Sign in',
                    loading: loading,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthSignInRequested()),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Signing in as ${state.role.name[0].toUpperCase()}${state.role.name.substring(1)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
