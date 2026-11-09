import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_store.dart';
import '../models/daily_expense.dart';
import '../models/daily_sale.dart';
import '../models/product_simulation.dart';
import '../models/user_business_profile.dart';
import 'benchmark_remote_data_source.dart';
import 'supabase_bootstrap.dart';
import 'supabase_config.dart';

/// Offline-first sync coordinator.
///
/// Writes always hit [LocalStore] first. These methods are fire-and-forget
/// upserts; failures are logged and the local row remains the source of truth.
/// Production can move [bootstrap] into a WorkManager job.
class SyncService {
  SyncService(this._localStore);

  final LocalStore _localStore;
  final BenchmarkRemoteDataSource _benchmarks = BenchmarkRemoteDataSource();

  bool _bootstrapping = false;
  bool _syncing = false;

  bool get _ready =>
      SupabaseConfig.isConfigured && SupabaseBootstrap.isInitialized;

  Future<void> bootstrap() async {
    if (!_ready || _bootstrapping) return;
    _bootstrapping = true;

    try {
      await _ensureAnonymousSession();
      final remoteBenchmarks = await _benchmarks.fetchBenchmarks();
      if (remoteBenchmarks.isNotEmpty) {
        await _localStore.saveBenchmarks(remoteBenchmarks);
      }
      await syncAll();
    } finally {
      _bootstrapping = false;
    }
  }

  Future<void> syncAll() async {
    if (!_ready || _syncing) return;
    _syncing = true;

    try {
      final userId = await _currentUserId();
      if (userId == null) return;

      final profile = _localStore.getProfile();
      if (profile != null) {
        await _upsert(
          'user_business_profile',
          {...profile.toMap(), 'user_id': userId},
        );
      }

      for (final product in _localStore.getProducts()) {
        await _upsert(
          'products_simulations',
          {...product.toMap(), 'user_id': userId},
        );
      }

      for (final expense in _localStore.getExpenses()) {
        await _upsert(
          'daily_expenses',
          {
            ...expense.toMap(),
            'date': _dateOnly(expense.date),
            'user_id': userId,
          },
        );
      }

      for (final sale in _localStore.getSales()) {
        await _upsert(
          'daily_sales',
          {
            ...sale.toMap(),
            'date': _dateOnly(sale.date),
            'user_id': userId,
          },
        );
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> syncProfile(UserBusinessProfile profile) async {
    final userId = await _currentUserId();
    if (userId == null) return;
    await _upsert(
      'user_business_profile',
      {...profile.toMap(), 'user_id': userId},
    );
  }

  Future<void> syncProduct(ProductSimulation product) async {
    final userId = await _currentUserId();
    if (userId == null) return;
    await _upsert(
      'products_simulations',
      {...product.toMap(), 'user_id': userId},
    );
  }

  Future<void> syncExpense(DailyExpense expense) async {
    final userId = await _currentUserId();
    if (userId == null) return;
    await _upsert(
      'daily_expenses',
      {
        ...expense.toMap(),
        'date': _dateOnly(expense.date),
        'user_id': userId,
      },
    );
  }

  Future<void> syncSale(DailySale sale) async {
    final userId = await _currentUserId();
    if (userId == null) return;
    await _upsert(
      'daily_sales',
      {
        ...sale.toMap(),
        'date': _dateOnly(sale.date),
        'user_id': userId,
      },
    );
  }

  String _dateOnly(DateTime value) =>
      value.toIso8601String().split('T').first;

  Future<String?> _currentUserId() async {
    if (!_ready) return null;

    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        await _ensureAnonymousSession();
      }
      return client.auth.currentUser?.id;
    } catch (error) {
      debugPrint('Supabase auth unavailable: $error');
      return null;
    }
  }

  Future<void> _ensureAnonymousSession() async {
    if (!_ready) return;

    try {
      final auth = Supabase.instance.client.auth;
      if (auth.currentSession == null) {
        await auth.signInAnonymously();
      }
    } catch (error) {
      debugPrint('Anonymous sign-in failed (enable it in Supabase Auth): $error');
    }
  }

  Future<void> _upsert(String table, Map<String, dynamic> data) async {
    try {
      await Supabase.instance.client.from(table).upsert(data, onConflict: 'id');
    } catch (error) {
      debugPrint('Sync $table failed: $error');
    }
  }
}
