import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../data/models/card_model.dart';
import '../../data/repositories/feed_repository.dart';
import 'feed_state.dart';

/// Notifier for managing feed state
class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _repository;
  final Logger _logger = Logger();
  
  List<CardModel> _promoCards = [];
  List<CardModel> _allContentCards = [];

  FeedNotifier(this._repository) : super(FeedState.initial());

  /// Initialize feed - fetch config and initial cards
  Future<void> initialize() async {
    try {
      state = state.copyWithLoading();

      // Fetch remote config
      final config = await _repository.getRemoteConfig();
      
      // Fetch promo cards
      _promoCards = await _repository.getPromoCards();

      // Fetch initial content cards
      final contentCards = await _repository.getFeedCards(
        page: 0,
        pageSize: config.pageSize,
      );

      // Sort by priority
      final sortedCards = _repository.sortByPriority(
        contentCards,
        config.categoryPriorities,
      );

      _allContentCards = sortedCards;

      // Inject promo cards
      final finalCards = _repository.injectPromoCards(
        sortedCards,
        _promoCards,
        config.promoCardInterval,
      );

      state = state.copyWithSuccess(
        cards: finalCards,
        config: config,
        currentPage: 0,
        hasReachedEnd: contentCards.length < config.pageSize,
      );

      _logger.i('Feed initialized with ${finalCards.length} cards');
    } catch (e) {
      _logger.e('Error initializing feed: $e');
      state = state.copyWithError(
        'Failed to load feed. Please try again.',
        isOffline: true,
      );
    }
  }

  /// Load more cards (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.config == null) {
      return;
    }

    try {
      state = state.copyWithLoadingMore();

      final nextPage = state.currentPage + 1;
      final config = state.config!;

      // Fetch next page
      final newCards = await _repository.getFeedCards(
        page: nextPage,
        pageSize: config.pageSize,
      );

      if (newCards.isEmpty) {
        state = state.copyWithSuccess(hasReachedEnd: true);
        return;
      }

      // Sort new cards by priority
      final sortedNewCards = _repository.sortByPriority(
        newCards,
        config.categoryPriorities,
      );

      // Add to all content cards
      _allContentCards.addAll(sortedNewCards);

      // Re-inject promo cards with all content
      final finalCards = _repository.injectPromoCards(
        _allContentCards,
        _promoCards,
        config.promoCardInterval,
      );

      state = state.copyWithSuccess(
        cards: finalCards,
        currentPage: nextPage,
        hasReachedEnd: newCards.length < config.pageSize,
      );

      _logger.i('Loaded page $nextPage with ${newCards.length} new cards');
    } catch (e) {
      _logger.e('Error loading more cards: $e');
      // Don't show error for pagination failures, just stop loading
      state = state.copyWithSuccess();
    }
  }

  /// Refresh feed
  Future<void> refresh() async {
    try {
      _allContentCards.clear();
      state = FeedState.initial();
      await initialize();
    } catch (e) {
      _logger.e('Error refreshing feed: $e');
      state = state.copyWithError('Failed to refresh feed');
    }
  }

  /// Clear cache and reload
  Future<void> clearCacheAndReload() async {
    try {
      await _repository.clearCache();
      await refresh();
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }
}
