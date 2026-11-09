import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initializeIfConfigured() async {
    if (!SupabaseConfig.isConfigured || _initialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      _initialized = true;
    } catch (error) {
      debugPrint('Supabase initialization skipped: $error');
    }
  }
}
