import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/widgets/add_user_dialog.dart';
import 'package:dreamflow/widgets/add_task_dialog.dart';
import 'package:dreamflow/theme.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _starsController;
  
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: 0,
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
    
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    _starsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _starsController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final dataManager = Provider.of<DataManager>(context);
    final premiumManager = Provider.of<PremiumManager>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Fond avec étoiles animées
          _buildAnimatedBackground(),
          
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isLandscape ? 20 : 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSpaceshipIllustration(isLandscape),
                  SizedBox(height: isLandscape ? 24 : 32),
                  _buildWelcomeContent(localizationService, isLandscape),
                  SizedBox(height: isLandscape ? 24 : 32),
                  _buildOnboardingSteps(localizationService, isLandscape),
                  SizedBox(height: isLandscape ? 24 : 32),
                  _buildActionButtons(localizationService, dataManager, premiumManager, isLandscape),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: OnboardingStarsPainter(
              animationValue: _starsAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpaceshipIllustration(bool isLandscape) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _pulseAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: isLandscape ? 120 : 160,
              height: isLandscape ? 120 : 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    SpaceColors.starYellow,
                    SpaceColors.nebulaPink,
                    SpaceColors.cosmicBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SpaceColors.starYellow.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: SpaceColors.nebulaPink.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anneaux rotatifs
                  Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: isLandscape ? 100 : 140,
                      height: isLandscape ? 100 : 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SpaceColors.starWhite.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -_rotateAnimation.value * 1.5,
                    child: Container(
                      width: isLandscape ? 80 : 120,
                      height: isLandscape ? 80 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SpaceColors.starWhite.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  
                  // Icône centrale
                  Container(
                    width: isLandscape ? 60 : 80,
                    height: isLandscape ? 60 : 80,
                    decoration: BoxDecoration(
                      color: SpaceColors.starWhite.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      size: isLandscape ? 32 : 40,
                      color: SpaceColors.spacePurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeContent(LocalizationService localizationService, bool isLandscape) {
    return Column(
      children: [
        // Titre principal
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
          ).createShader(bounds),
          child: Text(
            localizationService.isFrench ? 'Bienvenue dans RoutineKids!' : 'Welcome to RoutineKids!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isLandscape ? 28 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: isLandscape ? 8 : 12),
        
        // Sous-titre
        Text(
          localizationService.isFrench 
              ? 'L\'aventure spatiale des routines familiales commence ici !'
              : 'The space adventure of family routines starts here!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontSize: isLandscape ? 14 : null,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isLandscape ? 12 : 16),
        
        // Description
        Container(
          padding: EdgeInsets.all(isLandscape ? 16 : 20),
          decoration: BoxDecoration(
            color: SpaceColors.darkMatter.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.3),
            ),
          ),
          child: Text(
            localizationService.isFrench 
                ? 'Créez des routines magiques, suivez les progrès de votre équipage et explorez un univers où les tâches quotidiennes deviennent des missions spatiales extraordinaires !'
                : 'Create magical routines, track your crew\'s progress, and explore a universe where daily tasks become extraordinary space missions!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SpaceColors.starWhite,
              height: 1.5,
              fontSize: isLandscape ? 12 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingSteps(LocalizationService localizationService, bool isLandscape) {
    final steps = [
      {
        'icon': Icons.person_add,
        'title': localizationService.isFrench ? 'Ajouter des Astronautes' : 'Add Astronauts',
        'description': localizationService.isFrench 
            ? 'Recrutez les membres de votre équipage spatial'
            : 'Recruit your space crew members',
        'color': SpaceColors.cosmicBlue,
      },
      {
        'icon': Icons.assignment,
        'title': localizationService.isFrench ? 'Créer des Missions' : 'Create Missions',
        'description': localizationService.isFrench 
            ? 'Transformez les tâches en missions galactiques'
            : 'Transform tasks into galactic missions',
        'color': SpaceColors.nebulaPink,
      },
      {
        'icon': Icons.emoji_events,
        'title': localizationService.isFrench ? 'Gagner des Étoiles' : 'Earn Stars',
        'description': localizationService.isFrench 
            ? 'Completez les missions pour collecter des récompenses'
            : 'Complete missions to collect rewards',
        'color': SpaceColors.starYellow,
      },
    ];

    return Column(
      children: [
        Text(
          localizationService.isFrench ? 'Comment ça fonctionne' : 'How it works',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.w600,
            fontSize: isLandscape ? 16 : null,
          ),
        ),
        
        SizedBox(height: isLandscape ? 16 : 20),
        
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          
          return Container(
            margin: EdgeInsets.only(bottom: isLandscape ? 12 : 16),
            child: Row(
              children: [
                // Numéro et icône
                Container(
                  width: isLandscape ? 50 : 60,
                  height: isLandscape ? 50 : 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        step['color'] as Color,
                        (step['color'] as Color).withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (step['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        step['icon'] as IconData,
                        color: SpaceColors.starWhite,
                        size: isLandscape ? 20 : 24,
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: isLandscape ? 16 : 20,
                          height: isLandscape ? 16 : 20,
                          decoration: BoxDecoration(
                            color: SpaceColors.spaceBlack,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: SpaceColors.starWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 10 : 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: isLandscape ? 12 : 16),
                
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: isLandscape ? 12 : null,
                        ),
                      ),
                      SizedBox(height: isLandscape ? 2 : 4),
                      Text(
                        step['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                          fontSize: isLandscape ? 10 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(LocalizationService localizationService, DataManager dataManager, PremiumManager premiumManager, bool isLandscape) {
    return Column(
      children: [
        // Bouton principal - Ajouter un utilisateur
        SizedBox(
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SpaceColors.nebulaPink, SpaceColors.starYellow],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: SpaceColors.nebulaPink.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      Icons.person_add,
                      color: SpaceColors.spaceBlack,
                      size: isLandscape ? 20 : 24,
                    ),
                    label: Text(
                      localizationService.isFrench 
                          ? 'Ajouter mon Premier Astronaute'
                          : 'Add My First Astronaut',
                      style: TextStyle(
                        color: SpaceColors.spaceBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: isLandscape ? 12 : 16),
        
        // Bouton secondaire - Ajouter une tâche
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddTaskDialog(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: SpaceColors.cosmicBlue, width: 2),
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(
              Icons.add_task,
              color: SpaceColors.cosmicBlue,
              size: isLandscape ? 20 : 24,
            ),
            label: Text(
              localizationService.isFrench 
                  ? 'Créer ma Première Mission'
                  : 'Create My First Mission',
              style: TextStyle(
                color: SpaceColors.cosmicBlue,
                fontWeight: FontWeight.w600,
                fontSize: isLandscape ? 14 : 16,
              ),
            ),
          ),
        ),
        
        SizedBox(height: isLandscape ? 16 : 24),
        
        // Informations premium
        Container(
          padding: EdgeInsets.all(isLandscape ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SpaceColors.starYellow.withOpacity(0.1),
                SpaceColors.nebulaPink.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SpaceColors.starYellow.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: SpaceColors.starYellow,
                    size: isLandscape ? 16 : 20,
                  ),
                  SizedBox(width: isLandscape ? 6 : 8),
                  Text(
                    localizationService.isFrench ? 'Découverte Gratuite' : 'Free Discovery',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: SpaceColors.starYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 12 : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 4 : 8),
              Text(
                localizationService.isFrench 
                    ? 'Commencez avec 1 astronaute et 3 missions gratuites\\nPuis débloquez l\'univers complet avec Premium!'
                    : 'Start with 1 astronaut and 3 free missions\\nThen unlock the complete universe with Premium!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceColors.starWhiteSecondary,
                  fontSize: isLandscape ? 10 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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

/// Painter pour les étoiles animées en arrière-plan
class OnboardingStarsPainter extends CustomPainter {
  final double animationValue;
  
  OnboardingStarsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SpaceColors.starWhite.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Seed fixe pour consistance
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 1 + random.nextDouble() * 2;
      
      // Animation de scintillement
      final opacity = 0.3 + (math.sin(animationValue * 2 * math.pi + i) * 0.3).abs();
      paint.color = SpaceColors.starWhite.withOpacity(opacity);
      
      // Dessiner l'étoile
      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i + 0.5) * 72 - 90) * math.pi / 180;
      
      final outerX = center.dx + math.cos(outerAngle) * outerRadius;
      final outerY = center.dy + math.sin(outerAngle) * outerRadius;
      
      final innerX = center.dx + math.cos(innerAngle) * innerRadius;
      final innerY = center.dy + math.sin(innerAngle) * innerRadius;
      
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