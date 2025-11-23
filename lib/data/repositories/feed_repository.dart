import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../models/card_model.dart';
import '../models/remote_config_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

/// Repository for managing feed data with offline-first approach
class FeedRepository {
  final ApiService _apiService;
  final CacheService _cacheService;
  final Logger _logger = Logger();

  FeedRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  /// Fetch remote configuration with offline fallback
  Future<RemoteConfigModel> getRemoteConfig() async {
    try {
      // Try to fetch from API
      final config = await _apiService.fetchRemoteConfig();
      
      // Cache the config
      await _cacheService.saveRemoteConfig(config);
      
      return config;
    } catch (e) {
      _logger.w('Failed to fetch remote config, using cache: $e');
      
      // Fallback to cached config
      final cachedConfig = _cacheService.getCachedRemoteConfig();
      if (cachedConfig != null) {
        return cachedConfig;
      }
      
      // Ultimate fallback to default config
      _logger.w('No cached config available, using default');
      return RemoteConfigModel.defaultConfig();
    }
  }

  /// Fetch feed cards with pagination and offline support
  Future<List<CardModel>> getFeedCards({
    required int page,
    required int pageSize,
    bool forceRefresh = false,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (!isOnline && !forceRefresh) {
        _logger.i('Offline mode: Loading from cache');
        return _getCachedCards();
      }

      // Fetch from API
      final cards = await _apiService.fetchFeedCards(
        page: page,
        pageSize: pageSize,
      );

      // Cache the cards (only for first page to avoid cache bloat)
      if (page == 0) {
        await _cacheService.saveFeedCards(cards);
      }

      return cards;
    } catch (e) {
      _logger.e('Error fetching feed cards: $e');
      
      // Fallback to cache
      if (page == 0) {
        _logger.i('Falling back to cached cards');
        return _getCachedCards();
      }
      
      rethrow;
    }
  }

  /// Get promo cards
  Future<List<CardModel>> getPromoCards() async {
    try {
      return await _apiService.fetchPromoCards();
    } catch (e) {
      _logger.e('Error fetching promo cards: $e');
      return [];
    }
  }

  /// Get cached cards
  List<CardModel> _getCachedCards() {
    final cachedCards = _cacheService.getCachedFeedCards();
    if (cachedCards != null && cachedCards.isNotEmpty) {
      return cachedCards;
    }
    return [];
  }

  /// Sort cards by category priority
  List<CardModel> sortByPriority(
    List<CardModel> cards,
    Map<String, int> priorities,
  ) {
    final sortedCards = List<CardModel>.from(cards);
    
    sortedCards.sort((a, b) {
      // Only sort content cards
      if (a.type != 'content' || b.type != 'content') {
        return 0;
      }

      final categoryA = a.data['category'] as String?;
      final categoryB = b.data['category'] as String?;

      if (categoryA == null || categoryB == null) return 0;

      final priorityA = priorities[categoryA] ?? 999;
      final priorityB = priorities[categoryB] ?? 999;

      return priorityA.compareTo(priorityB);
    });

    return sortedCards;
  }

  /// Inject promo cards at specified intervals
  List<CardModel> injectPromoCards(
    List<CardModel> contentCards,
    List<CardModel> promoCards,
    int interval,
  ) {
    if (promoCards.isEmpty || interval <= 0) {
      return contentCards;
    }

    final result = <CardModel>[];
    int promoIndex = 0;

    for (int i = 0; i < contentCards.length; i++) {
      // Add content card
      result.add(contentCards[i]);

      // Inject promo card at intervals
      if ((i + 1) % interval == 0 && promoIndex < promoCards.length) {
        result.add(promoCards[promoIndex]);
        promoIndex = (promoIndex + 1) % promoCards.length;
      }
    }

    return result;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  /// Check if cache is valid
  bool isCacheValid() {
    return _cacheService.isCacheValid();
  }

  /// Get last update time
  DateTime? getLastUpdateTime() {
    return _cacheService.getLastUpdateTime();
  }
}
