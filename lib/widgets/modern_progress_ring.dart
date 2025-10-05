import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';

/// Modern progress ring with multiple design styles
class ModernProgressRing extends StatefulWidget {
  final int totalTasks;
  final int completedTasks;
  final double size;
  final ProgressRingStyle style;
  final Widget child;

  const ModernProgressRing({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
    this.size = 100,
    this.style = ProgressRingStyle.neonGlow,
    required this.child,
  }) : super(key: key);

  @override
  State<ModernProgressRing> createState() => _ModernProgressRingState();
}

class _ModernProgressRingState extends State<ModernProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _rotationController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Progress animation - consistent for all styles
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Pulse animation for completed state - subtle scale effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Rotation animation for quantum wave effect
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Sparkle animation - only for 100% completion
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _progressController.forward();
    
    // Only animate completion effects when 100% completed
    if (widget.completedTasks == widget.totalTasks && widget.totalTasks > 0) {
      _pulseController.repeat(reverse: true);
      _sparkleController.repeat();
    } else {
      _pulseController.stop();
      _sparkleController.stop();
    }
  }
  
  @override
  void didUpdateWidget(ModernProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedTasks != widget.completedTasks ||
        oldWidget.totalTasks != widget.totalTasks) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _progressAnimation,
        _sparkleAnimation,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow effect only when completed
              if (widget.completedTasks == widget.totalTasks && widget.totalTasks > 0)
                _buildBackgroundGlow(),
              
              // Main progress ring - consistent animation for all styles
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _getProgressPainter(),
              ),
              
              // Rotating sparkles only when 100% completed
              if (widget.completedTasks == widget.totalTasks && widget.totalTasks > 0)
                _buildSparkles(),
              
              // Completion badge
              if (widget.completedTasks == widget.totalTasks && widget.totalTasks > 0)
                _buildCompletionBadge(),
              
              // Child widget with subtle pulse when completed
              Transform.scale(
                scale: widget.completedTasks == widget.totalTasks && widget.totalTasks > 0 
                    ? _pulseAnimation.value 
                    : 1.0,
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildBackgroundGlow() {
    return Container(
      width: widget.size * 1.4,
      height: widget.size * 1.4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getGlowColor().withOpacity(0.4 * _pulseAnimation.value),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: _getGlowColor().withOpacity(0.2 * _pulseAnimation.value),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSparkles() {
    return RotationTransition(
      turns: _sparkleAnimation,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: SparklePainter(
          animationValue: _sparkleAnimation.value,
        ),
      ),
    );
  }
  
  Widget _buildCompletionBadge() {
    return Positioned(
      right: 0,
      top: 0,
      child: Transform.scale(
        scale: _sparkleAnimation.value,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: SpaceColors.galaxyGreen,
            shape: BoxShape.circle,
            border: Border.all(
              color: SpaceColors.starWhite,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.galaxyGreen.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }
  
  Color _getGlowColor() {
    switch (widget.style) {
      case ProgressRingStyle.neonGlow:
        return SpaceColors.galaxyGreen;
      case ProgressRingStyle.cosmicRainbow:
        return SpaceColors.nebulaPink;
      case ProgressRingStyle.crystalPrism:
        return SpaceColors.starYellow;
    }
  }
  
  CustomPainter _getProgressPainter() {
    switch (widget.style) {
      case ProgressRingStyle.neonGlow:
        return NeonGlowProgressPainter(
          totalTasks: widget.totalTasks,
          completedTasks: widget.completedTasks,
          progressAnimation: _progressAnimation.value,
        );
      case ProgressRingStyle.cosmicRainbow:
        return CosmicRainbowProgressPainter(
          totalTasks: widget.totalTasks,
          completedTasks: widget.completedTasks,
          progressAnimation: _progressAnimation.value,
        );
      case ProgressRingStyle.crystalPrism:
        return CrystalPrismProgressPainter(
          totalTasks: widget.totalTasks,
          completedTasks: widget.completedTasks,
          progressAnimation: _progressAnimation.value,
        );
    }
  }
}

enum ProgressRingStyle {
  neonGlow,
  cosmicRainbow,
  crystalPrism,
}

// Neon Glow Style - Electric blue/green neon effect
class NeonGlowProgressPainter extends CustomPainter {
  final int totalTasks;
  final int completedTasks;
  final double progressAnimation;

  NeonGlowProgressPainter({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalTasks == 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final strokeWidth = 6.0;
    
    // Outer neon glow ring
    final outerGlowPaint = Paint()
      ..color = SpaceColors.galaxyGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    // Main neon ring
    final neonPaint = Paint()
      ..color = SpaceColors.galaxyGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Inner bright core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Background dim ring
    final backgroundPaint = Paint()
      ..color = SpaceColors.darkMatterLight.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw background ring
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Calculate progress
    final progress = (completedTasks / totalTasks) * progressAnimation;
    final sweepAngle = 2 * math.pi * progress;
    
    // Draw outer glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      outerGlowPaint,
    );
    
    // Draw main neon ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      neonPaint,
    );
    
    // Draw inner bright core
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      corePaint,
    );
  }
  

  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cosmic Rainbow Style - Multi-colored gradient with galaxy effects
class CosmicRainbowProgressPainter extends CustomPainter {
  final int totalTasks;
  final int completedTasks;
  final double progressAnimation;

  CosmicRainbowProgressPainter({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalTasks == 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 8.0;
    
    // Background ring
    final backgroundPaint = Paint()
      ..color = SpaceColors.darkMatter.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Calculate progress
    final progress = (completedTasks / totalTasks) * progressAnimation;
    final sweepAngle = 2 * math.pi * progress;
    
    // Create rainbow gradient
    final rainbowGradient = SweepGradient(
      startAngle: -math.pi / 2,
      colors: [
        SpaceColors.nebulaPink,
        SpaceColors.starYellow,
        SpaceColors.galaxyGreen,
        SpaceColors.cosmicBlue,
        SpaceColors.spacePurple,
        SpaceColors.nebulaPink,
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );
    
    final rainbowPaint = Paint()
      ..shader = rainbowGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw rainbow progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      rainbowPaint,
    );
  }
  

  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Crystal Prism Style - Diamond-like segments with light refraction
class CrystalPrismProgressPainter extends CustomPainter {
  final int totalTasks;
  final int completedTasks;
  final double progressAnimation;

  CrystalPrismProgressPainter({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalTasks == 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Calculate crystal segments
    final segmentAngle = (2 * math.pi) / totalTasks;
    final completedSegments = (completedTasks * progressAnimation).floor();
    
    for (int i = 0; i < totalTasks; i++) {
      final startAngle = (-math.pi / 2) + (i * segmentAngle);
      final isCompleted = i < completedSegments;
      
      _drawCrystalSegment(
        canvas,
        center,
        radius,
        startAngle,
        segmentAngle,
        isCompleted,
        i,
      );
    }
  }
  
  void _drawCrystalSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double segmentAngle,
    bool isCompleted,
    int index,
  ) {
    final path = Path();
    
    // Create diamond-like segment
    final innerRadius = radius - 15;
    final outerRadius = radius;
    
    // Calculate points for diamond shape
    final midAngle = startAngle + (segmentAngle / 2);
    final gap = math.pi / 180 * 2; // 2 degree gap
    
    // Outer arc points
    final outerStart = Offset(
      center.dx + math.cos(startAngle + gap) * outerRadius,
      center.dy + math.sin(startAngle + gap) * outerRadius,
    );
    final outerEnd = Offset(
      center.dx + math.cos(startAngle + segmentAngle - gap) * outerRadius,
      center.dy + math.sin(startAngle + segmentAngle - gap) * outerRadius,
    );
    
    // Inner arc points
    final innerStart = Offset(
      center.dx + math.cos(startAngle + gap) * innerRadius,
      center.dy + math.sin(startAngle + gap) * innerRadius,
    );
    final innerEnd = Offset(
      center.dx + math.cos(startAngle + segmentAngle - gap) * innerRadius,
      center.dy + math.sin(startAngle + segmentAngle - gap) * innerRadius,
    );
    
    // Create diamond path
    path.moveTo(outerStart.dx, outerStart.dy);
    path.arcToPoint(
      outerEnd,
      radius: Radius.circular(outerRadius),
    );
    path.lineTo(innerEnd.dx, innerEnd.dy);
    path.arcToPoint(
      innerStart,
      radius: Radius.circular(innerRadius),
      clockwise: false,
    );
    path.close();
    
    // Paint based on completion status
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    if (isCompleted) {
      // Crystal gradient
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SpaceColors.starYellow.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
          SpaceColors.starYellow.withOpacity(0.9),
        ],
      );
      
      paint.shader = gradient.createShader(path.getBounds());
    } else {
      paint.color = SpaceColors.darkMatterLight.withOpacity(0.4);
    }
    
    canvas.drawPath(path, paint);
    
    // Add crystal highlight
    if (isCompleted) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawPath(path, highlightPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



// Sparkle effect painter
class SparklePainter extends CustomPainter {
  final double animationValue;

  SparklePainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final sparklePaint = Paint()
      ..color = SpaceColors.starYellow.withOpacity(0.8 * animationValue)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Draw sparkles at different positions
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final distance = radius * (0.7 + (i % 2) * 0.2);
      final sparkleSize = (2 + (i % 3)) * animationValue;
      
      final sparkleX = center.dx + math.cos(angle) * distance;
      final sparkleY = center.dy + math.sin(angle) * distance;
      
      _drawSparkle(canvas, Offset(sparkleX, sparkleY), sparkleSize, sparklePaint);
    }
  }
  
  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Create 6-pointed star
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final outerRadius = size;
      final innerRadius = size / 2;
      
      final outerX = center.dx + math.cos(angle) * outerRadius;
      final outerY = center.dy + math.sin(angle) * outerRadius;
      
      final innerX = center.dx + math.cos(angle + math.pi / 6) * innerRadius;
      final innerY = center.dy + math.sin(angle + math.pi / 6) * innerRadius;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}