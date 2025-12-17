import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/tradie_repository.dart';
import '../models/tradie_model.dart';

final tradieRepositoryProvider = Provider<TradieRepository>((ref) => TradieRepository());

final tradiesProvider = FutureProvider<List<TradieModel>>((ref) async {
  final repo = ref.watch(tradieRepositoryProvider);
  return repo.fetchTradies();
});

// Search query for tradies
final tradieSearchProvider = StateProvider<String>((ref) => '');
