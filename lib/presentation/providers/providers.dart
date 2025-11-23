import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../state/feed_notifier.dart';
import '../state/feed_state.dart';

/// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for Cache Service
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Provider for Feed Repository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  
  return FeedRepository(
    apiService: apiService,
    cacheService: cacheService,
  );
});

/// Provider for Feed State
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(repository);
});
