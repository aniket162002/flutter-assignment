import 'package:hive/hive.dart';

part 'card_model.g.dart';

/// Base class for all card types
@HiveType(typeId: 0)
class CardModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type;
  
  @HiveField(2)
  final Map<String, dynamic> data;
  
  @HiveField(3)
  final DateTime timestamp;

  CardModel({
    required this.id,
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Content Card Model
class ContentCard {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final String? author;
  final String? url;

  ContentCard({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.author,
    this.url,
  });

  factory ContentCard.fromJson(Map<String, dynamic> json) {
    return ContentCard(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      author: json['author'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'url': url,
    };
  }
}

/// Promo Card Model
class PromoCard {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String ctaText;
  final String ctaUrl;
  final String backgroundColor;
  final String? badge;

  PromoCard({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ctaText,
    required this.ctaUrl,
    required this.backgroundColor,
    this.badge,
  });

  factory PromoCard.fromJson(Map<String, dynamic> json) {
    return PromoCard(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      ctaText: json['ctaText'] as String,
      ctaUrl: json['ctaUrl'] as String,
      backgroundColor: json['backgroundColor'] as String? ?? '#FF6584',
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ctaText': ctaText,
      'ctaUrl': ctaUrl,
      'backgroundColor': backgroundColor,
      'badge': badge,
    };
  }
}
