import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/animals/presentation/bloc/animals_bloc.dart';
import '../../features/animals/presentation/pages/animals_list_page.dart';
import '../../features/animals/presentation/pages/cow_detail_page.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/booking/presentation/pages/animal_type_page.dart';
import '../../features/booking/presentation/pages/bakra_booking_page.dart';
import '../../features/booking/presentation/pages/customer_page.dart';
import '../../features/booking/presentation/pages/gaay_booking_page.dart';
import '../../features/booking/presentation/pages/review_booking_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/bloc/expenses_bloc.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_list_page.dart';
import '../../features/expenses/presentation/pages/income_expense_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/receipts/presentation/bloc/receipts_bloc.dart';
import '../../features/receipts/presentation/pages/receipt_detail_page.dart';
import '../../features/receipts/presentation/pages/receipts_list_page.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/bloc/org_settings_bloc.dart';
import '../../features/settings/presentation/bloc/rates_bloc.dart';
import '../../features/settings/presentation/pages/rates_page.dart';
import '../../features/settings/presentation/pages/receipt_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../di/injection.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _build(const SplashPage(), settings);

      case RouteNames.login:
        return _build(const LoginPage(), settings);

      case RouteNames.dashboard:
        return _build(
          BlocProvider(
            create: (_) => sl<DashboardBloc>(),
            child: const DashboardPage(),
          ),
          settings,
        );

      case RouteNames.settings:
        return _build(const SettingsPage(), settings);

      case RouteNames.receiptSettings:
        return _build(
          BlocProvider(
            create: (_) => sl<OrgSettingsBloc>(),
            child: const ReceiptSettingsPage(),
          ),
          settings,
        );

      case RouteNames.rates:
        return _build(
          BlocProvider(
            create: (_) => sl<RatesBloc>(),
            child: const RatesPage(),
          ),
          settings,
        );

      case RouteNames.newBooking:
        return _build(
          BlocProvider(
            create: (_) => sl<BookingBloc>(),
            child: const AnimalTypePage(),
          ),
          settings,
        );

      case RouteNames.gaayBooking:
        return _build(
          BlocProvider.value(
            value: settings.arguments as BookingBloc,
            child: const GaayBookingPage(),
          ),
          settings,
        );

      case RouteNames.bakraBooking:
        return _build(
          BlocProvider.value(
            value: settings.arguments as BookingBloc,
            child: const BakraBookingPage(),
          ),
          settings,
        );

      case RouteNames.customer:
        return _build(
          BlocProvider.value(
            value: settings.arguments as BookingBloc,
            child: const CustomerPage(),
          ),
          settings,
        );

      case RouteNames.reviewBooking:
        return _build(
          BlocProvider.value(
            value: settings.arguments as BookingBloc,
            child: const ReviewBookingPage(),
          ),
          settings,
        );

      case RouteNames.animals:
        return _build(
          BlocProvider(
            create: (_) => sl<AnimalsBloc>(),
            child: const AnimalsListPage(),
          ),
          settings,
        );

      case RouteNames.cowDetail:
        final tag = (settings.arguments as String?) ?? '';
        return _build(
          BlocProvider(
            create: (_) => sl<AnimalsBloc>(),
            child: CowDetailPage(tag: tag),
          ),
          settings,
        );

      case RouteNames.receipts:
        return _build(
          BlocProvider(
            create: (_) => sl<ReceiptsBloc>(),
            child: const ReceiptsListPage(),
          ),
          settings,
        );

      case RouteNames.receiptDetail:
        final id = (settings.arguments as String?) ?? '';
        return _build(
          BlocProvider(
            create: (_) => sl<ReceiptsBloc>(),
            child: ReceiptDetailPage(receiptId: id),
          ),
          settings,
        );

      case RouteNames.expenses:
        return _build(
          BlocProvider(
            create: (_) => sl<ExpensesBloc>(),
            child: const ExpensesListPage(),
          ),
          settings,
        );

      case RouteNames.addExpense:
        final editId = settings.arguments as String?;
        return _build(
          BlocProvider(
            create: (_) => sl<ExpensesBloc>()..add(const ExpensesLoadRequested()),
            child: AddExpensePage(editId: editId),
          ),
          settings,
        );

      case RouteNames.incomeExpense:
        return _build(
          BlocProvider(
            create: (_) => sl<ReportsBloc>(),
            child: const IncomeExpensePage(),
          ),
          settings,
        );

      case RouteNames.reports:
        return _build(
          BlocProvider(
            create: (_) => sl<ReportsBloc>(),
            child: const ReportsPage(),
          ),
          settings,
        );

      default:
        return _build(
          Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _build(
      Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
