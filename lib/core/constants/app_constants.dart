/// Application-wide constants
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://run.mocky.io/v3';
  static const String configEndpoint = '/f5c9c1f0-3d9a-4c5e-8b1a-2e3f4a5b6c7d';
  
  // Cache Keys
  static const String cacheBoxName = 'newsFeedCache';
  static const String configCacheKey = 'remote_config';
  static const String feedCacheKey = 'cached_feed';
  static const String lastUpdateKey = 'last_update_timestamp';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int preloadThreshold = 3;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheValidityDuration = Duration(hours: 24);
  
  // UI
  static const double cardBorderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Error Messages
  static const String networkErrorMessage = 'Unable to connect. Showing cached content.';
  static const String noDataMessage = 'No content available. Please check your connection.';
  static const String unknownErrorMessage = 'Something went wrong. Please try again.';
}
