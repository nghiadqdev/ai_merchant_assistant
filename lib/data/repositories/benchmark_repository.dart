import '../local/local_store.dart';
import '../models/system_benchmark.dart';
import '../remote/benchmark_remote_data_source.dart';

class BenchmarkRepository {
  BenchmarkRepository(this._localStore, this._remote);

  final LocalStore _localStore;
  final BenchmarkRemoteDataSource _remote;

  List<SystemBenchmark> get localBenchmarks => _localStore.getBenchmarks();

  Future<List<SystemBenchmark>> refreshFromRemote() async {
    final remote = await _remote.fetchBenchmarks();
    if (remote.isNotEmpty) {
      await _localStore.saveBenchmarks(remote);
      return remote;
    }
    return localBenchmarks;
  }
}
