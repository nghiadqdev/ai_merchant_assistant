import 'dart:async';

import '../local/local_store.dart';
import '../models/daily_sale.dart';
import '../remote/sync_service.dart';

class SaleRepository {
  SaleRepository(this._localStore, this._syncService);

  final LocalStore _localStore;
  final SyncService _syncService;

  Future<void> add(DailySale sale) async {
    await _localStore.addSale(sale);
    unawaited(_syncService.syncSale(sale));
  }
}
