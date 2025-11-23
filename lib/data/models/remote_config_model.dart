import 'package:hive/hive.dart';

part 'remote_config_model.g.dart';

/// Remote configuration model
@HiveType(typeId: 1)
class RemoteConfigModel extends HiveObject {
  @HiveField(0)
  final List<String> cardOrder;
  
  @HiveField(1)
  final Map<String, int> categoryPriorities;
  
  @HiveField(2)
  final int pageSize;
  
  @HiveField(3)
  final int promoCardInterval;
  
  @HiveField(4)
  final int preloadThreshold;
  
  @HiveField(5)
  final DateTime fetchedAt;

  RemoteConfigModel({
    required this.cardOrder,
    required this.categoryPriorities,
    required this.pageSize,
    required this.promoCardInterval,
    required this.preloadThreshold,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) {
    return RemoteConfigModel(
      cardOrder: List<String>.from(json['cardOrder'] as List),
      categoryPriorities: Map<String, int>.from(
        json['categoryPriorities'] as Map,
      ),
      pageSize: json['pagination']['pageSize'] as int,
      promoCardInterval: json['promoCardInterval'] as int,
      preloadThreshold: json['pagination']['preloadThreshold'] as int,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardOrder': cardOrder,
      'categoryPriorities': categoryPriorities,
      'pagination': {
        'pageSize': pageSize,
        'preloadThreshold': preloadThreshold,
      },
      'promoCardInterval': promoCardInterval,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  /// Default configuration for fallback
  factory RemoteConfigModel.defaultConfig() {
    return RemoteConfigModel(
      cardOrder: ['content', 'promo'],
      categoryPriorities: {
        'technology': 1,
        'business': 2,
        'sports': 3,
        'entertainment': 4,
        'health': 5,
      },
      pageSize: 10,
      promoCardInterval: 5,
      preloadThreshold: 3,
    );
  }

  RemoteConfigModel copyWith({
    List<String>? cardOrder,
    Map<String, int>? categoryPriorities,
    int? pageSize,
    int? promoCardInterval,
    int? preloadThreshold,
    DateTime? fetchedAt,
  }) {
    return RemoteConfigModel(
      cardOrder: cardOrder ?? this.cardOrder,
      categoryPriorities: categoryPriorities ?? this.categoryPriorities,
      pageSize: pageSize ?? this.pageSize,
      promoCardInterval: promoCardInterval ?? this.promoCardInterval,
      preloadThreshold: preloadThreshold ?? this.preloadThreshold,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
