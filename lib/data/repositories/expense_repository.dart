import 'dart:async';

import '../local/local_store.dart';
import '../models/daily_expense.dart';
import '../remote/sync_service.dart';

class ExpenseRepository {
  ExpenseRepository(this._localStore, this._syncService);

  final LocalStore _localStore;
  final SyncService _syncService;

  Future<void> add(DailyExpense expense) async {
    await _localStore.addExpense(expense);
    unawaited(_syncService.syncExpense(expense));
  }
}
