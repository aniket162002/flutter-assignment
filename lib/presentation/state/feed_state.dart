import 'package:equatable/equatable.dart';
import '../../data/models/card_model.dart';
import '../../data/models/remote_config_model.dart';

/// Feed state for managing the feed screen
class FeedState extends Equatable {
  final List<CardModel> cards;
  final RemoteConfigModel? config;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedEnd;
  final int currentPage;
  final bool isOffline;

  const FeedState({
    this.cards = const [],
    this.config,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.isOffline = false,
  });

  /// Initial state
  factory FeedState.initial() {
    return const FeedState(
      cards: [],
      config: null,
      isLoading: true,
      isLoadingMore: false,
      hasError: false,
      errorMessage: null,
      hasReachedEnd: false,
      currentPage: 0,
      isOffline: false,
    );
  }

  /// Loading state
  FeedState copyWithLoading() {
    return FeedState(
      cards: cards,
      config: config,
      isLoading: true,
      isLoadingMore: false,
      hasError: false,
      errorMessage: null,
      hasReachedEnd: hasReachedEnd,
      currentPage: currentPage,
      isOffline: isOffline,
    );
  }

  /// Loading more state
  FeedState copyWithLoadingMore() {
    return FeedState(
      cards: cards,
      config: config,
      isLoading: false,
      isLoadingMore: true,
      hasError: false,
      errorMessage: null,
      hasReachedEnd: hasReachedEnd,
      currentPage: currentPage,
      isOffline: isOffline,
    );
  }

  /// Success state
  FeedState copyWithSuccess({
    List<CardModel>? cards,
    RemoteConfigModel? config,
    int? currentPage,
    bool? hasReachedEnd,
    bool? isOffline,
  }) {
    return FeedState(
      cards: cards ?? this.cards,
      config: config ?? this.config,
      isLoading: false,
      isLoadingMore: false,
      hasError: false,
      errorMessage: null,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  /// Error state
  FeedState copyWithError(String message, {bool? isOffline}) {
    return FeedState(
      cards: cards,
      config: config,
      isLoading: false,
      isLoadingMore: false,
      hasError: true,
      errorMessage: message,
      hasReachedEnd: hasReachedEnd,
      currentPage: currentPage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        config,
        isLoading,
        isLoadingMore,
        hasError,
        errorMessage,
        hasReachedEnd,
        currentPage,
        isOffline,
      ];
}
