import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/system_benchmark.dart';
import 'supabase_bootstrap.dart';
import 'supabase_config.dart';

class BenchmarkRemoteDataSource {
  Future<List<SystemBenchmark>> fetchBenchmarks() async {
    if (!SupabaseConfig.isConfigured || !SupabaseBootstrap.isInitialized) {
      return const [];
    }

    try {
      final rows = await Supabase.instance.client
          .from('system_benchmarks')
          .select()
          .timeout(const Duration(seconds: 5));

      return rows
          .map(
            (row) => SystemBenchmark.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    } catch (error) {
      debugPrint('Could not pull system_benchmarks: $error');
      return const [];
    }
  }
}
