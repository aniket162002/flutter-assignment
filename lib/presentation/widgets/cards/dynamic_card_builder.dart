import 'package:flutter/material.dart';
import '../../../data/models/card_model.dart';
import 'content_card_widget.dart';
import 'promo_card_widget.dart';

/// Dynamic card builder that renders different card types
class DynamicCardBuilder extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final int index;

  const DynamicCardBuilder({
    super.key,
    required this.card,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (card.type.toLowerCase()) {
      case 'content':
        return _buildContentCard();
      case 'promo':
        return _buildPromoCard();
      default:
        return _buildFallbackCard(context);
    }
  }

  Widget _buildContentCard() {
    try {
      final content = ContentCard.fromJson(card.data);
      return ContentCardWidget(
        content: content,
        onTap: onTap,
        index: index,
      );
    } catch (e) {
      return _buildErrorCard('Error loading content card');
    }
  }

  Widget _buildPromoCard() {
    try {
      final promo = PromoCard.fromJson(card.data);
      return PromoCardWidget(
        promo: promo,
        onTap: onTap,
        index: index,
      );
    } catch (e) {
      return _buildErrorCard('Error loading promo card');
    }
  }

  Widget _buildFallbackCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Unknown Card Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Card type "${card.type}" is not supported yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

