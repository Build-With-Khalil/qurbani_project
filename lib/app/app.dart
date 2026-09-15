import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/services/navigation_service.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: MaterialApp(
        title: 'Alkhidmat Ijtemai Qurbani',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        navigatorKey: NavigationService().navigatorKey,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: RouteNames.splash,
      ),
    );
  }
}
