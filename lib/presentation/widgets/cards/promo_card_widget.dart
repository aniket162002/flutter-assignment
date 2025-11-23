import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/card_model.dart';
import 'dart:math' as math;

/// Ultra-Premium Promo Card with Glassmorphism and Particle Effects
class PromoCardWidget extends StatefulWidget {
  final PromoCard promo;
  final VoidCallback? onTap;
  final int index;

  const PromoCardWidget({
    super.key,
    required this.promo,
    this.onTap,
    this.index = 0,
  });

  @override
  State<PromoCardWidget> createState() => _PromoCardWidgetState();
}

class _PromoCardWidgetState extends State<PromoCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildPromoCard(context),
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    final backgroundColor = _parseColor(widget.promo.backgroundColor);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Animated Gradient Background
              _buildAnimatedBackground(backgroundColor),

              // Floating Particles
              _buildFloatingParticles(),

              // Glassmorphic Content Layer
              _buildGlassmorphicContent(context, backgroundColor),

              // Shimmer Effect
              _buildShimmerEffect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Color backgroundColor) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.8),
                  backgroundColor.withOpacity(0.9),
                  backgroundColor,
                ],
                stops: [
                  0.0,
                  _shimmerController.value * 0.5,
                  _shimmerController.value,
                  1.0,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(
          animation: _shimmerController,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContent(BuildContext context, Color backgroundColor) {
    return Positioned.fill(
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge and Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.promo.badge != null)
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: _buildPremiumBadge(backgroundColor),
                    ),
                  BounceInDown(
                    duration: const Duration(milliseconds: 700),
                    child: _buildSparkleIcon(),
                  ),
                ],
              ),

              const Spacer(),

              // Title with Glow Effect
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: _buildGlowingTitle(context),
              ),

              const SizedBox(height: 12),

              // Description
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: _buildDescription(context),
              ),

              const Spacer(),

              // CTA Button
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: _buildPremiumCTAButton(context, backgroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerController.value * 2, -1.0),
                end: Alignment(1.0 + _shimmerController.value * 2, 1.0),
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumBadge(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: backgroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            widget.promo.badge!,
            style: GoogleFonts.montserrat(
              color: backgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkleIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildGlowingTitle(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Colors.white70],
      ).createShader(bounds),
      child: Text(
        widget.promo.title,
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      widget.promo.description,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: Colors.white.withOpacity(0.95),
        height: 1.5,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPremiumCTAButton(BuildContext context, Color backgroundColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.promo.ctaText,
                  style: GoogleFonts.poppins(
                    color: backgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: backgroundColor,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.secondaryColor;
    }
  }
}

/// Custom painter for floating particles effect
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _ParticlePainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animation.value + (i * 0.1)) % 1.0;
      
      final particleY = y + (offset * 50) - 25;
      final opacity = (1.0 - offset).clamp(0.0, 1.0);
      
      paint.color = color.withOpacity(opacity * 0.6);
      
      canvas.drawCircle(
        Offset(x, particleY),
        2 + (random.nextDouble() * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
