import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/persistence/supabase_init.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_org_settings.dart';
import '../../features/settings/domain/usecases/save_org_settings.dart';
import '../../features/settings/domain/usecases/get_rates.dart';
import '../../features/settings/domain/usecases/save_rates.dart';
import '../../features/settings/presentation/bloc/org_settings_bloc.dart';
import '../../features/settings/presentation/bloc/rates_bloc.dart';

import '../../features/booking/data/datasources/booking_local_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_booking.dart';
import '../../features/booking/domain/usecases/search_customers.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';

import '../../features/animals/data/datasources/animals_local_datasource.dart';
import '../../features/animals/data/repositories/animals_repository_impl.dart';
import '../../features/animals/domain/repositories/animals_repository.dart';
import '../../features/animals/domain/usecases/get_animals.dart';
import '../../features/animals/domain/usecases/get_cow_detail.dart';
import '../../features/animals/presentation/bloc/animals_bloc.dart';

import '../../features/receipts/data/datasources/receipts_local_datasource.dart';
import '../../features/receipts/data/repositories/receipts_repository_impl.dart';
import '../../features/receipts/domain/repositories/receipts_repository.dart';
import '../../features/receipts/domain/usecases/get_receipts.dart';
import '../../features/receipts/domain/usecases/get_receipt.dart';
import '../../features/receipts/presentation/bloc/receipts_bloc.dart';

import '../../features/expenses/data/datasources/expenses_local_datasource.dart';
import '../../features/expenses/data/repositories/expenses_repository_impl.dart';
import '../../features/expenses/domain/repositories/expenses_repository.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/save_expense.dart';
import '../../features/expenses/presentation/bloc/expenses_bloc.dart';

import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_season_summary.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseInit.client);

  // Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerFactory(
    () => AuthBloc(signIn: sl(), signOut: sl(), getCurrentUser: sl()),
  );

  // Settings (org + rates)
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetOrgSettings(sl()));
  sl.registerLazySingleton(() => SaveOrgSettings(sl()));
  sl.registerLazySingleton(() => GetRates(sl()));
  sl.registerLazySingleton(() => SaveRates(sl()));
  sl.registerFactory(() => OrgSettingsBloc(getOrg: sl(), saveOrg: sl()));
  sl.registerFactory(() => RatesBloc(getRates: sl(), saveRates: sl()));

  // Booking
  sl.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => SearchCustomers(sl()));
  sl.registerFactory(
    () => BookingBloc(
      createBooking: sl(),
      searchCustomers: sl(),
      getRates: sl(),
    ),
  );

  // Animals
  sl.registerLazySingleton<AnimalsLocalDataSource>(
    () => AnimalsLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AnimalsRepository>(
    () => AnimalsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetAnimals(sl()));
  sl.registerLazySingleton(() => GetCowDetail(sl()));
  sl.registerFactory(
    () => AnimalsBloc(getAnimals: sl(), getCowDetail: sl()),
  );

  // Receipts
  sl.registerLazySingleton<ReceiptsLocalDataSource>(
    () => ReceiptsLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReceiptsRepository>(
    () => ReceiptsRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetReceipts(sl()));
  sl.registerLazySingleton(() => GetReceipt(sl()));
  sl.registerFactory(
    () => ReceiptsBloc(getReceipts: sl(), getReceipt: sl()),
  );

  // Expenses
  sl.registerLazySingleton<ExpensesLocalDataSource>(
    () => ExpensesLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => SaveExpense(sl()));
  sl.registerFactory(
    () => ExpensesBloc(getExpenses: sl(), saveExpense: sl()),
  );

  // Dashboard
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetDashboardSummary(sl()));
  sl.registerFactory(() => DashboardBloc(getSummary: sl()));

  // Reports
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(client: sl()),
  );
  sl.registerLazySingleton(() => GetSeasonSummary(sl()));
  sl.registerFactory(() => ReportsBloc(getSummary: sl()));
}
