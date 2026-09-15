import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'core/persistence/supabase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseInit.init();
  await setupDependencies();
  runApp(const App());
}
