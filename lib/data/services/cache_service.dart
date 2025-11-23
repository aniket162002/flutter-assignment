import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../models/card_model.dart';
import '../models/remote_config_model.dart';

/// Local storage service using Hive for offline-first architecture
class CacheService {
  late Box _cacheBox;
  final Logger _logger = Logger();

  /// Initialize Hive and open cache box
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CardModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(RemoteConfigModelAdapter());
      }
      
      _cacheBox = await Hive.openBox(AppConstants.cacheBoxName);
      _logger.i('Cache service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing cache service: $e');
      rethrow;
    }
  }

  /// Save remote config to cache
  Future<void> saveRemoteConfig(RemoteConfigModel config) async {
    try {
      await _cacheBox.put(AppConstants.configCacheKey, config);
      await _cacheBox.put(
        AppConstants.lastUpdateKey,
        DateTime.now().toIso8601String(),
      );
      _logger.i('Remote config saved to cache');
    } catch (e) {
      _logger.e('Error saving remote config: $e');
    }
  }

  /// Get cached remote config
  RemoteConfigModel? getCachedRemoteConfig() {
    try {
      final config = _cacheBox.get(AppConstants.configCacheKey);
      if (config != null && config is RemoteConfigModel) {
        _logger.i('Retrieved remote config from cache');
        return config;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached remote config: $e');
      return null;
    }
  }

  /// Save feed cards to cache
  Future<void> saveFeedCards(List<CardModel> cards) async {
    try {
      // Convert cards to JSON for storage
      final cardsJson = cards.map((card) => card.toJson()).toList();
      await _cacheBox.put(AppConstants.feedCacheKey, cardsJson);
      await _cacheBox.put(
        AppConstants.lastUpdateKey,
        DateTime.now().toIso8601String(),
      );
      _logger.i('Saved ${cards.length} cards to cache');
    } catch (e) {
      _logger.e('Error saving feed cards: $e');
    }
  }

  /// Get cached feed cards
  List<CardModel>? getCachedFeedCards() {
    try {
      final cardsJson = _cacheBox.get(AppConstants.feedCacheKey);
      if (cardsJson != null && cardsJson is List) {
        final cards = cardsJson
            .map((json) => CardModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        _logger.i('Retrieved ${cards.length} cards from cache');
        return cards;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached feed cards: $e');
      return null;
    }
  }

  /// Check if cache is valid
  bool isCacheValid() {
    try {
      final lastUpdate = _cacheBox.get(AppConstants.lastUpdateKey);
      if (lastUpdate == null) return false;

      final lastUpdateTime = DateTime.parse(lastUpdate as String);
      final difference = DateTime.now().difference(lastUpdateTime);
      
      return difference < AppConstants.cacheValidityDuration;
    } catch (e) {
      _logger.e('Error checking cache validity: $e');
      return false;
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      _logger.i('Cache cleared successfully');
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }

  /// Get last update timestamp
  DateTime? getLastUpdateTime() {
    try {
      final lastUpdate = _cacheBox.get(AppConstants.lastUpdateKey);
      if (lastUpdate != null) {
        return DateTime.parse(lastUpdate as String);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting last update time: $e');
      return null;
    }
  }
}
