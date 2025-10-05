import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class ModernTaskCard extends StatefulWidget {
  final Task task;
  final DayOfWeek currentDay;
  final VoidCallback onTap;
  final bool isCompact;

  const ModernTaskCard({
    Key? key,
    required this.task,
    required this.currentDay,
    required this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<ModernTaskCard> createState() => _ModernTaskCardState();
}

class _ModernTaskCardState extends State<ModernTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _completionController;
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _completionAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _confettiAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Set up animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    // Set initial state based on completion status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.task.isCompletedForDay(widget.currentDay)) {
          _completionController.value = 1.0;
          _glowController.repeat(reverse: true);
        } else {
          _completionController.value = 0.0;
          _glowController.value = 0.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _completionController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    // Get current task state from context
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final currentTask = dataManager.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );
    
    // Store the state before toggling
    final wasCompleted = currentTask.isCompletedForDay(widget.currentDay);
    
    widget.onTap();
    
    // Force immediate state update
    setState(() {});
    
    // Wait for state to update then handle animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final updatedTask = dataManager.tasks.firstWhere(
          (t) => t.id == widget.task.id,
          orElse: () => widget.task,
        );
        final isNowCompleted = updatedTask.isCompletedForDay(widget.currentDay);
        
        if (!wasCompleted && isNowCompleted) {
          // Task just completed - start celebration
          _completionController.forward();
          _shakeController.forward();
          _confettiController.forward();
          _glowController.repeat(reverse: true);
          
          // Reset shake after animation
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _shakeController.reset();
            }
          });
        } else if (wasCompleted && !isNowCompleted) {
          // Task just uncompleted - reset everything immediately
          _completionController.stop();
          _completionController.value = 0.0; // Force value to 0
          _glowController.stop();
          _glowController.value = 0.0; // Force value to 0
          _confettiController.stop();
          _confettiController.value = 0.0; // Force value to 0
        }
        
        // Force another rebuild to ensure everything is updated
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        // Get the updated task from DataManager instead of using the old widget.task
        final currentTask = dataManager.tasks.firstWhere(
          (t) => t.id == widget.task.id,
          orElse: () => widget.task,
        );
        final isCompleted = currentTask.isCompletedForDay(widget.currentDay);
        final cardWidth = widget.isCompact ? 70.0 : 100.0;
        final cardHeight = widget.isCompact ? 70.0 : 100.0;
        final iconSize = widget.isCompact ? 28.0 : 40.0;

        return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _scaleController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _completionAnimation,
            _shakeAnimation,
            _glowAnimation,
            _confettiAnimation,
          ]),
          builder: (context, child) {
            // Shake effect calculation
            final shakeOffset = _shakeAnimation.value * 
                math.sin(_shakeAnimation.value * math.pi * 8) * 3;
            
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main card with dynamic shadows and glow
                    Container(
                      width: cardWidth,
                      height: cardHeight,
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [
                                  SpaceColors.galaxyGreen,
                                  SpaceColors.starYellow,
                                  SpaceColors.galaxyGreen,
                                ],
                                stops: [
                                  0.0,
                                  0.5 + (0.3 * math.sin(_glowAnimation.value * math.pi * 2)),
                                  1.0,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : SpaceColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted 
                              ? SpaceColors.galaxyGreen.withOpacity(0.8)
                              : SpaceColors.spacePurple.withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          // Main shadow
                          BoxShadow(
                            color: isCompleted
                                ? SpaceColors.galaxyGreen.withOpacity(0.4)
                                : SpaceColors.spacePurple.withOpacity(0.2),
                            blurRadius: _isHovered ? 20 : 10,
                            offset: const Offset(0, 4),
                            spreadRadius: isCompleted ? 2 : 0,
                          ),
                          // Glow effect for completed tasks
                          if (isCompleted)
                            BoxShadow(
                              color: SpaceColors.galaxyGreen.withOpacity(0.6 * _glowAnimation.value),
                              blurRadius: 30,
                              offset: const Offset(0, 0),
                              spreadRadius: 8,
                            ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sparkle background effect for completed tasks
                          if (isCompleted)
                            ...List.generate(5, (index) {
                              final angle = (index * 72) * math.pi / 180;
                              final radius = 25.0;
                              final x = radius * math.cos(angle + _glowAnimation.value * math.pi * 2);
                              final y = radius * math.sin(angle + _glowAnimation.value * math.pi * 2);
                              
                              return Positioned(
                                left: cardWidth / 2 + x - 6,
                                top: cardHeight / 2 + y - 6,
                                child: Transform.scale(
                                  scale: 0.5 + (_glowAnimation.value * 0.5),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Colors.white.withOpacity(0.8 * _glowAnimation.value),
                                  ),
                                ),
                              );
                            }),
                          
                          // Main task icon or custom image with pulse effect
                          widget.task.customImage != null
                              ? // Custom image filling the entire card
                                Positioned.fill(
                                  child: Transform.scale(
                                    scale: isCompleted ? (1.0 + (_completionAnimation.value * 0.1)) : 1.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.memory(
                                            widget.task.customImage!,
                                            fit: BoxFit.cover,
                                          ),
                                           // Overlay for better text readability and completion effect
                                           Container(
                                             decoration: BoxDecoration(
                                               gradient: LinearGradient(
                                                 begin: Alignment.topCenter,
                                                 end: Alignment.bottomCenter,
                                                 colors: _completionAnimation.value > 0.0
                                                   ? [
                                                       SpaceColors.galaxyGreen.withOpacity(0.3 * _completionAnimation.value),
                                                       SpaceColors.galaxyGreen.withOpacity(0.5 * _completionAnimation.value),
                                                       SpaceColors.galaxyGreen.withOpacity(0.7 * _completionAnimation.value),
                                                     ]
                                                   : [
                                                       Colors.transparent,
                                                       Colors.black.withOpacity(0.3),
                                                       Colors.black.withOpacity(0.6),
                                                     ],
                                                 stops: const [0.0, 0.7, 1.0],
                                               ),
                                             ),
                                           ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : // Default icon for tasks without custom image
                                Transform.scale(
                                  scale: isCompleted ? (1.0 + (_completionAnimation.value * 0.2)) : 1.0,
                                  child: Icon(
                                    widget.task.icon,
                                    size: iconSize,
                                    color: isCompleted 
                                        ? Colors.white
                                        : widget.task.iconColor,
                                  ),
                                ),
                          
                          // Task title
                          if (!widget.isCompact)
                            Positioned(
                              bottom: 8,
                              left: 4,
                              right: 4,
                              child: Consumer<LocalizationService>(
                                builder: (context, localizationService, child) {
                                  return Text(
                                    localizationService.getTaskTitle(widget.task.title),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isCompleted 
                                          ? Colors.white
                                          : SpaceColors.starWhiteSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                          
                          // Time period indicator
                          if (!widget.isCompact && widget.task.timePeriod != TimePeriod.both)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTimePeriodColor(widget.task.timePeriod).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getTimePeriodIcon(widget.task.timePeriod),
                                  color: SpaceColors.starWhite,
                                  size: 10,
                                ),
                              ),
                            ),
                          
                          // Completion checkmark with bounce animation
                          if (isCompleted)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Transform.scale(
                                scale: _completionAnimation.value,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: SpaceColors.galaxyGreen,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Confetti explosion effect
                    if (isCompleted && _confettiAnimation.value > 0)
                      ...List.generate(12, (index) {
                        final angle = (index * 30) * math.pi / 180;
                        final distance = 60 * _confettiAnimation.value;
                        final x = distance * math.cos(angle);
                        final y = distance * math.sin(angle);
                        final colors = [
                          SpaceColors.starYellow,
                          SpaceColors.nebulaPink,
                          SpaceColors.galaxyGreen,
                          SpaceColors.cosmicBlue,
                        ];
                        
                        return Positioned(
                          left: cardWidth / 2 + x,
                          top: cardHeight / 2 + y,
                          child: Transform.rotate(
                            angle: _confettiAnimation.value * math.pi * 4,
                            child: Transform.scale(
                              scale: 1.0 - _confettiAnimation.value,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    
                    // Ring expansion effect on completion
                    if (isCompleted && _completionAnimation.value > 0)
                      Positioned(
                        left: cardWidth / 2 - 40,
                        top: cardHeight / 2 - 40,
                        child: Transform.scale(
                          scale: _completionAnimation.value * 2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SpaceColors.galaxyGreen.withOpacity(
                                  0.6 * (1.0 - _completionAnimation.value)
                                ),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
      },
    );
  }

  Color _getTimePeriodColor(TimePeriod period) {
    switch (period) {
      case TimePeriod.morning:
        return SpaceColors.starYellow;
      case TimePeriod.evening:
        return SpaceColors.spacePurple;
      case TimePeriod.both:
        return SpaceColors.cosmicBlue;
    }
  }

  IconData _getTimePeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.morning:
        return Icons.wb_sunny;
      case TimePeriod.evening:
        return Icons.nights_stay;
      case TimePeriod.both:
        return Icons.all_inclusive;
    }
  }
}

// Weekly progress indicator for task cards
class TaskProgressIndicator extends StatelessWidget {
  final Task task;
  final double size;

  const TaskProgressIndicator({
    Key? key,
    required this.task,
    this.size = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedDays = task.assignedDays
        .where((day) => task.isCompletedForDay(day))
        .length;
    
    final totalDays = task.assignedDays.length;
    final progress = totalDays > 0 ? completedDays / totalDays : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SpaceColors.darkMatter,
              border: Border.all(
                color: SpaceColors.spacePurple.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          
          // Progress arc
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressArcPainter(
              progress: progress,
              color: progress >= 1.0 
                  ? SpaceColors.galaxyGreen 
                  : SpaceColors.nebulaPink,
              strokeWidth: 3,
            ),
          ),
          
          // Progress text
          Text(
            '$completedDays/$totalDays',
            style: TextStyle(
              color: SpaceColors.starWhite,
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}