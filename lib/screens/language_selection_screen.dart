import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _floatController;
  late AnimationController _titleController;
  
  late Animation<double> _starAnimation;
  late Animation<double> _floatAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  
  AppLanguage? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    
    _starController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.linear,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));
    
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _starController.repeat();
    _floatController.repeat(reverse: true);
    _titleController.forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    _floatController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _selectLanguage(AppLanguage language) async {
    setState(() {
      _selectedLanguage = language;
    });
    
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    // Update language
    dataManager.updateLanguage(language);
    localizationService.setLanguage(language);
    
    // Mark language as selected
    await dataManager.prefs.setBool('language_selected', true);
    
    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate to next screen (onboarding or home)
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SpaceColors.spaceGradient,
        ),
        child: Stack(
          children: [
            // Animated starfield background
            _buildStarfieldBackground(),
            
            // Main content
            SafeArea(
              child: isLandscape 
                ? _buildLandscapeLayout()
                : _buildPortraitLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarfieldBackground() {
    return AnimatedBuilder(
      animation: _starAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: LanguageStarsPainter(animationValue: _starAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _buildWelcomeHeader(),
          const Spacer(flex: 3),
          _buildLanguageOptions(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Left side - Welcome header
          Expanded(
            flex: 2,
            child: _buildWelcomeHeader(),
          ),
          
          const SizedBox(width: 32),
          
          // Right side - Language options
          Expanded(
            flex: 3,
            child: Center(
              child: _buildLanguageOptions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return SlideTransition(
      position: _titleSlideAnimation,
      child: FadeTransition(
        opacity: _titleFadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo/icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SpaceColors.nebulaGradient,
                boxShadow: [
                  BoxShadow(
                    color: SpaceColors.nebulaPink.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.family_restroom,
                size: 60,
                color: SpaceColors.starWhite,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App title
            Text(
              'RoutineKids',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Welcome to your space adventure!\nBienvenue dans votre aventure spatiale !',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SpaceColors.starWhiteSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Choose your language\nChoisissez votre langue',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // Language options
        Column(
          children: [
            _buildLanguageCard(
              flag: '🇺🇸',
              title: 'English',
              subtitle: 'Continue in English',
              language: AppLanguage.english,
              isSelected: _selectedLanguage == AppLanguage.english,
            ),
            
            const SizedBox(height: 20),
            
            _buildLanguageCard(
              flag: '🇫🇷', 
              title: 'Français',
              subtitle: 'Continuer en français',
              language: AppLanguage.french,
              isSelected: _selectedLanguage == AppLanguage.french,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String flag,
    required String title,
    required String subtitle,
    required AppLanguage language,
    required bool isSelected,
  }) {
    final isAnimating = _selectedLanguage == language;
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        final floatOffset = math.sin(_floatAnimation.value * 2 * math.pi) * 2;
        
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: InkWell(
            onTap: () => _selectLanguage(language),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? SpaceColors.nebulaGradient
                  : LinearGradient(
                      colors: [
                        SpaceColors.darkMatter,
                        SpaceColors.darkMatterLight,
                      ],
                    ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? SpaceColors.nebulaPink
                    : SpaceColors.spacePurple.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? SpaceColors.nebulaPink.withOpacity(0.3)
                      : SpaceColors.spacePurple.withOpacity(0.1),
                    blurRadius: isSelected ? 20 : 8,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Flag
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SpaceColors.spaceBlackLight,
                      border: Border.all(
                        color: isSelected 
                          ? SpaceColors.starWhite
                          : SpaceColors.starWhiteTertiary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: SpaceColors.starWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SpaceColors.starWhiteSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                        ? SpaceColors.starWhite
                        : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                          ? SpaceColors.starWhite
                          : SpaceColors.starWhiteTertiary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: SpaceColors.nebulaPink,
                        )
                      : null,
                  ),
                  
                  // Loading indicator for selected
                  if (isAnimating) ...[
                    const SizedBox(width: 16),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(SpaceColors.starWhite),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter pour les étoiles animées spécifique à la sélection de langue
class LanguageStarsPainter extends CustomPainter {
  final double animationValue;
  
  LanguageStarsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SpaceColors.starWhite.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Generate consistent stars based on screen size
    final random = math.Random(42); // Fixed seed for consistency
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 1;
      
      // Create twinkling effect
      final twinkle = math.sin((animationValue * 2 * math.pi) + (i * 0.5));
      final opacity = 0.3 + (twinkle.abs() * 0.7);
      
      paint.color = SpaceColors.starWhite.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y),
        starSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}