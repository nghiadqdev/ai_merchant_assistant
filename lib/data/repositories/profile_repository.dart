import 'dart:async';

import '../local/local_store.dart';
import '../models/user_business_profile.dart';
import '../remote/sync_service.dart';

class ProfileRepository {
  ProfileRepository(this._localStore, this._syncService);

  final LocalStore _localStore;
  final SyncService _syncService;

  Future<void> save(UserBusinessProfile profile) async {
    await _localStore.saveProfile(profile);
    unawaited(_syncService.syncProfile(profile));
  }
}
