import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/local/hive_local_store.dart';
import 'data/remote/supabase_bootstrap.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Needed for DateFormat('E', 'vi') and the Vietnamese date picker.
  await initializeDateFormatting('vi');

  // Optional cloud layer. Without --dart-define values the app runs 100% local.
  await SupabaseBootstrap.initializeIfConfigured();

  final localStore = await HiveLocalStore.open();
  final bootstrap = BootstrapData(
    profile: localStore.getProfile(),
    benchmarks: localStore.getBenchmarks(),
  );

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        bootstrapProvider.overrideWithValue(bootstrap),
      ],
      child: const AiMerchantApp(),
    ),
  );
}
