import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/widgets/add_user_dialog.dart';
import 'package:dreamflow/widgets/add_task_dialog.dart';
import 'package:dreamflow/theme.dart';

class EmptyStateScreen extends StatefulWidget {
  const EmptyStateScreen({Key? key}) : super(key: key);

  @override
  State<EmptyStateScreen> createState() => _EmptyStateScreenState();
}

class _EmptyStateScreenState extends State<EmptyStateScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _starsController;
  
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _starsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.linear,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _starsController.repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final dataManager = Provider.of<DataManager>(context);
    final premiumManager = Provider.of<PremiumManager>(context);
    
    return Scaffold(
      backgroundColor: SpaceColors.spaceBlack,
      body: Stack(
        children: [
          // Animated starfield background
          _buildStarfieldBackground(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header with app name
                  _buildHeader(localizationService),
                  
                  // Main empty state content
                  Expanded(
                    child: _buildEmptyStateContent(localizationService, dataManager, premiumManager),
                  ),
                  
                  // Premium info footer
                  _buildPremiumInfo(localizationService),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarfieldBackground() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: StarfieldPainter(animationValue: _starsAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocalizationService localizationService) {
    return Column(
      children: [
        // App logo and title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SpaceColors.starYellow.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: SpaceColors.spaceBlack,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
              ).createShader(bounds),
              child: Text(
                'RoutineKids',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          localizationService.isFrench 
              ? 'L\'aventure spatiale commence !'
              : 'The space adventure begins!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: SpaceColors.starWhiteSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateContent(LocalizationService localizationService, DataManager dataManager, PremiumManager premiumManager) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating rocket illustration
            AnimatedBuilder(
              animation: Listenable.merge([_floatAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            SpaceColors.cosmicBlue,
                            SpaceColors.spacePurple,
                            SpaceColors.nebulaPink,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SpaceColors.cosmicBlue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orbital rings
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SpaceColors.starWhite.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SpaceColors.starWhite.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                          ),
                          
                          // Central icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: SpaceColors.starWhite.withOpacity(0.95),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.family_restroom,
                              size: 40,
                              color: SpaceColors.spacePurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Welcome message
            Text(
              localizationService.isFrench 
                  ? 'Prêt pour le Décollage !'
                  : 'Ready for Launch!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              localizationService.isFrench 
                  ? 'Bienvenue dans l\'univers des routines familiales.\nCommencez par ajouter des membres de votre équipage\net créez des missions spatiales extraordinaires !'
                  : 'Welcome to the universe of family routines.\nStart by adding crew members\nand create extraordinary space missions!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SpaceColors.starWhiteSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            _buildActionButtons(localizationService, dataManager, premiumManager),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LocalizationService localizationService, DataManager dataManager, PremiumManager premiumManager) {
    return Column(
      children: [
        // Primary button - Add user
        SizedBox(
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SpaceColors.nebulaPink, SpaceColors.starYellow],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: SpaceColors.nebulaPink.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.person_add,
                    color: SpaceColors.spaceBlack,
                    size: 24,
                  ),
                  label: Text(
                    localizationService.isFrench 
                        ? '🚀 Recruter Premier Astronaute'
                        : '🚀 Recruit First Astronaut',
                    style: const TextStyle(
                      color: SpaceColors.spaceBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary button - Add task
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddTaskDialog(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: SpaceColors.cosmicBlue, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(
              Icons.assignment_add,
              color: SpaceColors.cosmicBlue,
              size: 24,
            ),
            label: Text(
              localizationService.isFrench 
                  ? '🎯 Créer Première Mission'
                  : '🎯 Create First Mission',
              style: const TextStyle(
                color: SpaceColors.cosmicBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumInfo(LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SpaceColors.starYellow.withOpacity(0.1),
            SpaceColors.nebulaPink.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.starYellow.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: SpaceColors.starYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizationService.isFrench ? 'Découverte Gratuite' : 'Free Discovery',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SpaceColors.starYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizationService.isFrench 
                ? 'Version gratuite : 1 astronaute • 3 missions • Style Arc-en-ciel\nDébloquez Premium pour un univers illimité !'
                : 'Free version: 1 astronaut • 3 missions • Rainbow style\nUnlock Premium for unlimited universe!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SpaceColors.starWhiteSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }
}

/// Custom painter for animated starfield background
class StarfieldPainter extends CustomPainter {
  final double animationValue;
  
  StarfieldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Fixed seed for consistency
    
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 0.5 + random.nextDouble() * 2;
      
      // Twinkling animation
      final twinkle = 0.3 + (math.sin(animationValue * 2 * math.pi + i * 0.1) * 0.4).abs();
      paint.color = SpaceColors.starWhite.withOpacity(twinkle);
      
      // Draw star
      canvas.drawCircle(Offset(x, y), starSize, paint);
      
      // Add sparkle effect for some stars
      if (i % 5 == 0) {
        paint.color = SpaceColors.starYellow.withOpacity(twinkle * 0.8);
        canvas.drawCircle(Offset(x, y), starSize * 0.6, paint);
      }
    }
    
    // Add some larger, colorful stars
    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final colors = [SpaceColors.nebulaPink, SpaceColors.cosmicBlue, SpaceColors.starYellow];
      final color = colors[i % colors.length];
      
      final twinkle = 0.4 + (math.sin(animationValue * math.pi + i * 0.2) * 0.3).abs();
      paint.color = color.withOpacity(twinkle);
      
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}