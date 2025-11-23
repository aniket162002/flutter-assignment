import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/card_model.dart';

/// Enhanced Content Card Widget with advanced animations and interactions
class ContentCardWidget extends StatefulWidget {
  final ContentCard content;
  final VoidCallback? onTap;
  final int index;

  const ContentCardWidget({
    super.key,
    required this.content,
    this.onTap,
    this.index = 0,
  });

  @override
  State<ContentCardWidget> createState() => _ContentCardWidgetState();
}

class _ContentCardWidgetState extends State<ContentCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _toggleBookmark(),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: 'Save',
              borderRadius: BorderRadius.circular(16),
            ),
            SlidableAction(
              onPressed: (_) => _shareCard(),
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap?.call();
            },
            onTapCancel: () => _controller.reverse(),
            child: _buildCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Theme.of(context).cardTheme.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Image Section with Parallax Effect
              _buildImageSection(context),

              // Content Section with Glassmorphism
              _buildContentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Main Image with Hero Animation
        Hero(
          tag: 'card_${widget.content.id}',
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: widget.content.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[300]!,
                      Colors.grey[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[300]!,
                      Colors.grey[200]!,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),

        // Category Badge with Animation
        Positioned(
          top: 12,
          left: 12,
          child: SlideInLeft(
            duration: const Duration(milliseconds: 500),
            child: _buildCategoryBadge(context),
          ),
        ),

        // Bookmark Button
        Positioned(
          top: 12,
          right: 12,
          child: BounceInDown(
            duration: const Duration(milliseconds: 500),
            child: _buildBookmarkButton(),
          ),
        ),

        // Reading Time Indicator
        Positioned(
          bottom: 12,
          right: 12,
          child: FadeIn(
            duration: const Duration(milliseconds: 700),
            child: _buildReadingTime(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with Custom Font
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: Text(
              widget.content.title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Text(
              widget.content.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Metadata Row with Icons
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildMetadataRow(context),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final categoryColors = {
      'technology': const Color(0xFF6C63FF),
      'business': const Color(0xFFFF6584),
      'sports': const Color(0xFF4ECDC4),
      'entertainment': const Color(0xFFFDCB6E),
      'health': const Color(0xFF00B894),
      'science': const Color(0xFF74B9FF),
    };

    final color = categoryColors[widget.content.category.toLowerCase()] ??
        AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(widget.content.category),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            widget.content.category.toUpperCase(),
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: _isBookmarked ? AppTheme.primaryColor : Colors.grey[700],
        ),
        onPressed: _toggleBookmark,
        iconSize: 22,
      ),
    );
  }

  Widget _buildReadingTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${_calculateReadingTime()} min read',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    final timeAgo = _getTimeAgo(widget.content.publishedAt);

    return Row(
      children: [
        // Source with Icon
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.content.source,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Time Ago
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.thumb_up_outlined,
          label: '${_getRandomLikes()}',
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: '${_getRandomComments()}',
          onTap: () {},
        ),
        const Spacer(),
        _buildReadMoreButton(context),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadMoreButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Read More',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business_center;
      case 'sports':
        return Icons.sports_soccer;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.favorite;
      case 'science':
        return Icons.science;
      default:
        return Icons.article;
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  int _calculateReadingTime() {
    final wordCount = widget.content.description.split(' ').length +
        widget.content.title.split(' ').length;
    return (wordCount / 200).ceil().clamp(1, 10);
  }

  int _getRandomLikes() {
    return (widget.content.id.hashCode % 500) + 50;
  }

  int _getRandomComments() {
    return (widget.content.id.hashCode % 100) + 10;
  }
}
