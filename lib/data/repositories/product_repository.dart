import 'dart:async';

import '../local/local_store.dart';
import '../models/product_simulation.dart';
import '../remote/sync_service.dart';

class ProductRepository {
  ProductRepository(this._localStore, this._syncService);

  final LocalStore _localStore;
  final SyncService _syncService;

  Future<void> save(ProductSimulation product) async {
    await _localStore.saveProduct(product);
    unawaited(_syncService.syncProduct(product));
  }
}
