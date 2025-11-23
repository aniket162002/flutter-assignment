import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/cards/dynamic_card_builder.dart';
import '../widgets/loading/card_shimmer.dart';

/// Enhanced Feed Screen with premium animations and interactions
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).initialize();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show/hide scroll to top button with animation
    if (_scrollController.offset > 500 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
      _fabController.forward();
    } else if (_scrollController.offset <= 500 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
      _fabController.reverse();
    }

    // Load more when near bottom
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load at 80% scroll

    if (currentScroll >= threshold) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(feedProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, state),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: _buildBody(state),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, state) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                AppTheme.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NewsFeed',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Stay Updated',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Offline indicator with badge
        if (state.isOffline)
          FadeIn(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Offline',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Notification Bell
        BounceInDown(
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: badges.Badge(
              badgeContent: Text(
                '3',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.all(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        ),

        // Menu
        FadeInDown(
          duration: const Duration(milliseconds: 700),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'refresh') {
                _onRefresh();
              } else if (value == 'clear_cache') {
                ref.read(feedProvider.notifier).clearCacheAndReload();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text('Refresh', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppTheme.secondaryColor),
                    const SizedBox(width: 12),
                    Text('Clear Cache', style: GoogleFonts.inter()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(state) {
    if (state.isLoading && state.cards.isEmpty) {
      return const LoadingShimmer(itemCount: 5);
    }

    if (state.hasError && state.cards.isEmpty) {
      return _buildErrorView(state.errorMessage ?? 'An error occurred');
    }

    if (state.cards.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(top: 100, bottom: 20),
        itemCount: state.cards.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at bottom
          if (index == state.cards.length) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading more...',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final card = state.cards[index];

          return DynamicCardBuilder(
            card: card,
            index: index,
            onTap: () => _onCardTap(card),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Text(
                'Oops!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BounceInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Text(
                'No Content Available',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'Pull down to refresh',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_showScrollToTop) return null;

    return ScaleTransition(
      scale: _fabController,
      child: FloatingActionButton.extended(
        onPressed: _scrollToTop,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.arrow_upward),
        label: Text(
          'Top',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        elevation: 8,
      ),
    );
  }

  void _onCardTap(card) {
    // Handle card tap - could navigate to detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tapped card: ${card.id}',
          style: GoogleFonts.inter(),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
