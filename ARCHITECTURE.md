# Architecture Documentation

## Overview

This document provides an in-depth explanation of the application architecture, design decisions, and implementation patterns used in the NewsFeed application.

## Architecture Pattern

### Clean Architecture + MVVM

The application follows **Clean Architecture** principles combined with **MVVM (Model-View-ViewModel)** pattern, ensuring:

- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Business logic is isolated and easily testable
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code

## Layer Structure

### 1. Core Layer (`lib/core/`)

**Purpose**: Contains application-wide utilities, constants, and configurations.

#### Components:
- **Constants** (`constants/`): Centralized configuration values
  - API endpoints
  - Cache keys
  - UI constants
  - Error messages

- **Theme** (`theme/`): Application theming
  - Color palette
  - Typography
  - Component themes
  - Light/Dark mode support

**Why**: Centralizing constants and theme prevents magic numbers and ensures consistency.

### 2. Data Layer (`lib/data/`)

**Purpose**: Handles data operations, API calls, and local storage.

#### Components:

##### Models (`models/`)
- **CardModel**: Base model for all card types
- **ContentCard**: News/article content model
- **PromoCard**: Promotional content model
- **RemoteConfigModel**: Configuration from remote API

**Design Decision**: Using Hive annotations for efficient local storage with type safety.

##### Services (`services/`)

**ApiService**:
```dart
class ApiService {
  - Dio HTTP client
  - Request/Response interceptors
  - Error handling
  - Retry logic
  - Logging
}
```

**CacheService**:
```dart
class CacheService {
  - Hive initialization
  - Data persistence
  - Cache validation
  - Expiry management
}
```

**Why Separate Services**: Single Responsibility Principle - each service handles one concern.

##### Repository (`repositories/`)

**FeedRepository**:
- Orchestrates data sources (API + Cache)
- Implements offline-first strategy
- Business logic for data operations
- Priority sorting
- Promo card injection

**Pattern**: Repository Pattern
- Abstracts data source details
- Provides clean API to presentation layer
- Handles data source switching (network/cache)

### 3. Presentation Layer (`lib/presentation/`)

**Purpose**: UI and user interaction logic.

#### Components:

##### State Management (`state/` & `providers/`)

**FeedState**:
```dart
class FeedState {
  - Immutable state class
  - Multiple state variants (loading, success, error)
  - Uses Equatable for value comparison
}
```

**FeedNotifier**:
```dart
class FeedNotifier extends StateNotifier<FeedState> {
  - State transitions
  - Business logic coordination
  - Error handling
  - Pagination logic
}
```

**Providers**:
```dart
- apiServiceProvider
- cacheServiceProvider
- feedRepositoryProvider
- feedProvider (StateNotifier)
```

**Why Riverpod**:
1. Compile-time safety
2. No BuildContext needed
3. Easy testing
4. Automatic disposal
5. Provider composition

##### Screens (`screens/`)

**FeedScreen**:
- Main UI composition
- Scroll handling
- Pull-to-refresh
- Navigation
- User interactions

**Responsibility**: Only UI logic, delegates business logic to StateNotifier.

##### Widgets (`widgets/`)

**Reusable Components**:
- `ContentCardWidget`: Displays news content
- `PromoCardWidget`: Displays promotions
- `DynamicCardBuilder`: Type-based widget selection
- `CardShimmer`: Loading states

**Design Principle**: Single Responsibility - each widget has one job.

## Data Flow

### 1. Initial Load

```
User Opens App
    ↓
FeedScreen.initState()
    ↓
FeedNotifier.initialize()
    ↓
FeedRepository.getRemoteConfig()
    ↓
ApiService.fetchRemoteConfig() → Success
    ↓                               ↓
CacheService.save()          FeedRepository.getFeedCards()
    ↓                               ↓
FeedRepository.sortByPriority()
    ↓
FeedRepository.injectPromoCards()
    ↓
FeedNotifier updates state
    ↓
FeedScreen rebuilds with data
```

### 2. Offline Scenario

```
User Opens App (No Internet)
    ↓
FeedNotifier.initialize()
    ↓
FeedRepository.getRemoteConfig()
    ↓
ApiService.fetchRemoteConfig() → Error
    ↓
CacheService.getCachedConfig()
    ↓
FeedRepository.getFeedCards()
    ↓
ApiService.fetchFeedCards() → Error
    ↓
CacheService.getCachedCards()
    ↓
FeedNotifier updates state (with offline flag)
    ↓
FeedScreen shows cached data + offline indicator
```

### 3. Pagination

```
User Scrolls to 80% of feed
    ↓
ScrollController detects threshold
    ↓
FeedNotifier.loadMore()
    ↓
FeedRepository.getFeedCards(page: nextPage)
    ↓
ApiService.fetchFeedCards()
    ↓
FeedRepository.sortByPriority()
    ↓
FeedRepository.injectPromoCards() (re-inject with all cards)
    ↓
FeedNotifier updates state
    ↓
FeedScreen appends new cards
```

## Key Algorithms

### 1. Priority Sorting

**Problem**: Display content based on category importance.

**Solution**:
```dart
List<CardModel> sortByPriority(
  List<CardModel> cards,
  Map<String, int> priorities,
) {
  return cards..sort((a, b) {
    final priorityA = priorities[a.category] ?? 999;
    final priorityB = priorities[b.category] ?? 999;
    return priorityA.compareTo(priorityB);
  });
}
```

**Complexity**: O(n log n)

### 2. Promo Card Injection

**Problem**: Insert promo cards at regular intervals, maintaining position across pagination.

**Challenge**: When loading page 2, promo cards must appear at correct global positions, not just within page 2.

**Solution**:
```dart
List<CardModel> injectPromoCards(
  List<CardModel> allContentCards,  // All loaded content
  List<CardModel> promoCards,
  int interval,
) {
  final result = <CardModel>[];
  int promoIndex = 0;

  for (int i = 0; i < allContentCards.length; i++) {
    result.add(allContentCards[i]);
    
    // Inject promo at every Nth position
    if ((i + 1) % interval == 0 && promoIndex < promoCards.length) {
      result.add(promoCards[promoIndex]);
      promoIndex = (promoIndex + 1) % promoCards.length; // Cycle through promos
    }
  }
  
  return result;
}
```

**Example**:
- Interval = 5
- Content cards: C1, C2, C3, C4, C5, C6, C7, C8, C9, C10
- Promo cards: P1, P2
- Result: C1, C2, C3, C4, C5, **P1**, C6, C7, C8, C9, C10, **P2**

### 3. Offline-First Strategy

**Problem**: Provide seamless experience regardless of connectivity.

**Solution**:
```dart
Future<T> fetchWithCache<T>({
  required Future<T> Function() networkCall,
  required T? Function() cacheCall,
  required Future<void> Function(T) saveCache,
}) async {
  try {
    // Try network first
    final data = await networkCall();
    await saveCache(data);
    return data;
  } catch (e) {
    // Fallback to cache
    final cached = cacheCall();
    if (cached != null) return cached;
    rethrow;
  }
}
```

**Benefits**:
- Fast initial load (from cache)
- Works offline
- Always shows latest when online
- Reduces server load

## State Management Deep Dive

### Riverpod Provider Hierarchy

```
ProviderScope (Root)
    ↓
cacheServiceProvider (Provider)
    ↓
apiServiceProvider (Provider)
    ↓
feedRepositoryProvider (Provider)
    ↓
feedProvider (StateNotifierProvider)
    ↓
FeedScreen (Consumer)
```

### State Transitions

```
Initial State
    ↓
Loading State (isLoading: true)
    ↓
Success State (cards: [...], isLoading: false)
    ↓
Loading More State (isLoadingMore: true)
    ↓
Success State (cards: [...more], isLoadingMore: false)
```

### Error Handling

```
Any State
    ↓
Error Occurs
    ↓
Error State (hasError: true, errorMessage: "...")
    ↓
User Retries
    ↓
Loading State
```

## Performance Optimizations

### 1. Image Caching
- **Library**: cached_network_image
- **Strategy**: Memory + Disk cache
- **Benefit**: Instant image display on revisit

### 2. Lazy Loading
- **Implementation**: ListView.builder
- **Benefit**: Only visible items rendered

### 3. Const Constructors
- **Usage**: All stateless widgets
- **Benefit**: Reduced rebuilds

### 4. Provider Scoping
- **Strategy**: Minimal provider scope
- **Benefit**: Targeted rebuilds only

### 5. Pagination Threshold
- **Value**: 80% scroll
- **Benefit**: Preload before user reaches end

## Testing Strategy

### Unit Tests
- Models: Serialization/Deserialization
- Repository: Business logic
- Notifier: State transitions

### Widget Tests
- Card widgets: Rendering
- Screen: User interactions

### Integration Tests
- Full user flows
- Offline scenarios
- Error handling

## Security Considerations

1. **API Keys**: Should be in environment variables (not hardcoded)
2. **HTTPS Only**: All network requests over HTTPS
3. **Input Validation**: Validate all user inputs
4. **Cache Encryption**: Sensitive data should be encrypted

## Scalability

### Adding New Card Types

1. Create model in `data/models/`
2. Add case in `DynamicCardBuilder`
3. Create widget in `presentation/widgets/cards/`
4. Update API service mock data

### Adding New Features

1. Create feature folder in `presentation/`
2. Add state management
3. Create repository if needed
4. Add to navigation

## Conclusion

This architecture ensures:
- ✅ Clean separation of concerns
- ✅ Easy testing
- ✅ Maintainable codebase
- ✅ Scalable structure
- ✅ Production-ready quality

The combination of Clean Architecture, MVVM, and Riverpod provides a robust foundation for building complex, maintainable Flutter applications.
