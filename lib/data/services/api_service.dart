import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../models/card_model.dart';
import '../models/remote_config_model.dart';

/// API Service for handling all network requests
class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Fetch remote configuration
  Future<RemoteConfigModel> fetchRemoteConfig() async {
    try {
      // In production, this would be a real API endpoint
      // For demo, we'll return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockConfig = {
        'cardOrder': ['content', 'promo'],
        'categoryPriorities': {
          'technology': 1,
          'business': 2,
          'sports': 3,
          'entertainment': 4,
          'health': 5,
          'science': 6,
        },
        'pagination': {
          'pageSize': 10,
          'preloadThreshold': 3,
        },
        'promoCardInterval': 5,
      };

      return RemoteConfigModel.fromJson(mockConfig);
    } catch (e) {
      _logger.e('Error fetching remote config: $e');
      rethrow;
    }
  }

  /// Fetch feed cards with pagination
  Future<List<CardModel>> fetchFeedCards({
    required int page,
    required int pageSize,
  }) async {
    try {
      // Mock API delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Generate mock content cards
      final List<CardModel> cards = [];
      final startIndex = page * pageSize;
      
      for (int i = 0; i < pageSize; i++) {
        final index = startIndex + i;
        final categories = [
          'technology',
          'business',
          'sports',
          'entertainment',
          'health',
          'science'
        ];
        final category = categories[index % categories.length];
        
        cards.add(
          CardModel(
            id: 'content_$index',
            type: 'content',
            data: {
              'id': 'content_$index',
              'title': _generateTitle(category, index),
              'description': _generateDescription(category, index),
              'category': category,
              'imageUrl': _generateImageUrl(category, index),
              'source': _generateSource(category),
              'publishedAt': DateTime.now()
                  .subtract(Duration(hours: index))
                  .toIso8601String(),
              'author': _generateAuthor(index),
              'url': 'https://example.com/article/$index',
            },
          ),
        );
      }
      
      return cards;
    } catch (e) {
      _logger.e('Error fetching feed cards: $e');
      rethrow;
    }
  }

  /// Fetch promo cards
  Future<List<CardModel>> fetchPromoCards() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final promos = [
        CardModel(
          id: 'promo_1',
          type: 'promo',
          data: {
            'id': 'promo_1',
            'title': '🎉 Special Offer!',
            'description': 'Get 50% off on premium subscription. Limited time offer!',
            'imageUrl': 'https://picsum.photos/seed/promo1/400/200',
            'ctaText': 'Claim Now',
            'ctaUrl': 'https://example.com/offer',
            'backgroundColor': '#FF6584',
            'badge': 'HOT',
          },
        ),
        CardModel(
          id: 'promo_2',
          type: 'promo',
          data: {
            'id': 'promo_2',
            'title': '📱 Download Our App',
            'description': 'Experience the best news reading app. Available on iOS & Android.',
            'imageUrl': 'https://picsum.photos/seed/promo2/400/200',
            'ctaText': 'Download',
            'ctaUrl': 'https://example.com/app',
            'backgroundColor': '#6C63FF',
            'badge': 'NEW',
          },
        ),
        CardModel(
          id: 'promo_3',
          type: 'promo',
          data: {
            'id': 'promo_3',
            'title': '🌟 Premium Features',
            'description': 'Unlock ad-free reading, offline mode, and exclusive content.',
            'imageUrl': 'https://picsum.photos/seed/promo3/400/200',
            'ctaText': 'Upgrade',
            'ctaUrl': 'https://example.com/premium',
            'backgroundColor': '#4ECDC4',
          },
        ),
      ];
      
      return promos;
    } catch (e) {
      _logger.e('Error fetching promo cards: $e');
      rethrow;
    }
  }

  // Helper methods for generating mock data
  String _generateTitle(String category, int index) {
    final titles = {
      'technology': [
        'AI Revolution: How Machine Learning is Transforming Industries',
        'New Smartphone Breaks All Performance Records',
        'Quantum Computing Breakthrough Announced',
        'Tech Giants Invest Billions in Green Energy',
        'Cybersecurity Threats on the Rise in 2024',
      ],
      'business': [
        'Stock Market Hits New All-Time High',
        'Startup Raises \$100M in Series B Funding',
        'Global Economy Shows Signs of Recovery',
        'Major Merger Reshapes Industry Landscape',
        'Cryptocurrency Market Sees Massive Volatility',
      ],
      'sports': [
        'Championship Final: Underdog Team Claims Victory',
        'Olympic Athlete Breaks 20-Year-Old Record',
        'Transfer News: Star Player Signs Record Deal',
        'Tournament Update: Favorites Advance to Finals',
        'Sports Science: New Training Methods Show Results',
      ],
      'entertainment': [
        'Blockbuster Film Breaks Box Office Records',
        'Award-Winning Series Returns for New Season',
        'Music Festival Announces Star-Studded Lineup',
        'Celebrity Interview: Exclusive Behind-the-Scenes',
        'Streaming Platform Unveils Original Content',
      ],
      'health': [
        'Medical Breakthrough: New Treatment Shows Promise',
        'Study Reveals Benefits of Mediterranean Diet',
        'Mental Health Awareness Campaign Launches',
        'Fitness Trends: What\'s Popular in 2024',
        'Vaccine Development: Latest Research Updates',
      ],
      'science': [
        'Space Mission Discovers Potential Life Signs',
        'Climate Study Reveals Urgent Action Needed',
        'Archaeological Find Rewrites Ancient History',
        'Renewable Energy Efficiency Reaches New Peak',
        'Ocean Exploration Uncovers Unknown Species',
      ],
    };
    
    final categoryTitles = titles[category] ?? titles['technology']!;
    return categoryTitles[index % categoryTitles.length];
  }

  String _generateDescription(String category, int index) {
    final descriptions = {
      'technology': 'Latest developments in technology sector show promising results. Experts predict significant impact on daily life and business operations worldwide.',
      'business': 'Market analysts report strong performance across multiple sectors. Investors remain optimistic about future growth prospects and opportunities.',
      'sports': 'In an exciting match that kept fans on the edge of their seats, teams delivered outstanding performances showcasing skill and determination.',
      'entertainment': 'Critics and audiences alike praise the latest release. The production quality and storytelling have set new standards in the industry.',
      'health': 'Health professionals emphasize the importance of these findings. The research could lead to improved treatments and better patient outcomes.',
      'science': 'Scientists collaborate on groundbreaking research that could change our understanding. The implications extend far beyond initial expectations.',
    };
    
    return descriptions[category] ?? descriptions['technology']!;
  }

  String _generateImageUrl(String category, int index) {
    return 'https://picsum.photos/seed/$category$index/800/600';
  }

  String _generateSource(String category) {
    final sources = {
      'technology': 'TechCrunch',
      'business': 'Bloomberg',
      'sports': 'ESPN',
      'entertainment': 'Variety',
      'health': 'HealthLine',
      'science': 'Nature',
    };
    
    return sources[category] ?? 'News Source';
  }

  String _generateAuthor(int index) {
    final authors = [
      'Sarah Johnson',
      'Michael Chen',
      'Emily Rodriguez',
      'David Kim',
      'Jessica Williams',
      'Robert Taylor',
    ];
    
    return authors[index % authors.length];
  }
}
