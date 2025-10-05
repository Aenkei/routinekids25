import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';

class StarryBackground extends StatefulWidget {
  final Widget child;
  final int numberOfStars;

  const StarryBackground({
    Key? key,
    required this.child,
    this.numberOfStars = 50,
  }) : super(key: key);

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _slowTwinkleController;
  late List<Star> _stars;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Fast twinkling animation for some stars
    _twinkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Slow twinkling animation for other stars
    _slowTwinkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Generate random stars
    _generateStars();
  }

  void _generateStars() {
    _stars = List.generate(widget.numberOfStars, (index) {
      return Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1, // Size between 1-4
        opacity: _random.nextDouble() * 0.6 + 0.3, // Opacity between 0.3-0.9
        twinkleSpeed: _random.nextBool() ? TwinkleSpeed.fast : TwinkleSpeed.slow,
        color: _getRandomStarColor(),
      );
    });
  }

  Color _getRandomStarColor() {
    final colors = [
      SpaceColors.starWhite,
      SpaceColors.starYellow,
      SpaceColors.nebulaPink.withOpacity(0.8),
      SpaceColors.galaxyGreen.withOpacity(0.7),
      SpaceColors.cosmicBlue.withOpacity(0.8),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _slowTwinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: SpaceColors.spaceGradient,
          ),
        ),
        
        // Animated stars
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_twinkleController, _slowTwinkleController]),
            builder: (context, child) {
              return CustomPaint(
                painter: StarryPainter(
                  stars: _stars,
                  fastTwinkleValue: _twinkleController.value,
                  slowTwinkleValue: _slowTwinkleController.value,
                ),
              );
            },
          ),
        ),
        
        // Main content
        widget.child,
      ],
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final TwinkleSpeed twinkleSpeed;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
    required this.color,
  });
}

enum TwinkleSpeed { fast, slow }

class StarryPainter extends CustomPainter {
  final List<Star> stars;
  final double fastTwinkleValue;
  final double slowTwinkleValue;

  StarryPainter({
    required this.stars,
    required this.fastTwinkleValue,
    required this.slowTwinkleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final paint = Paint()
        ..color = star.color.withOpacity(
          star.opacity * _getTwinkleOpacity(star.twinkleSpeed)
        )
        ..style = PaintingStyle.fill;

      final center = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      // Draw main star body
      canvas.drawCircle(center, star.size, paint);

      // Add sparkle effect for larger stars
      if (star.size > 2.5) {
        _drawSparkle(canvas, center, star.size, paint);
      }
    }
  }

  double _getTwinkleOpacity(TwinkleSpeed speed) {
    switch (speed) {
      case TwinkleSpeed.fast:
        return 0.3 + (0.7 * fastTwinkleValue);
      case TwinkleSpeed.slow:
        return 0.4 + (0.6 * slowTwinkleValue);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final sparklePaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw cross sparkle
    final sparkleSize = size * 1.5;
    
    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - sparkleSize, center.dy),
      Offset(center.dx + sparkleSize, center.dy),
      sparklePaint,
    );
    
    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - sparkleSize),
      Offset(center.dx, center.dy + sparkleSize),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}