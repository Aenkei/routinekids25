import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/widgets/premium_pricing_dialog.dart';
import 'package:dreamflow/theme.dart';

/// Dialog Premium simplifié qui redirige vers le nouveau dialog de prix
class PremiumDialog extends StatefulWidget {
  final PremiumLimitationType limitationType;
  final VoidCallback? onUpgrade;

  const PremiumDialog({
    Key? key,
    required this.limitationType,
    this.onUpgrade,
  }) : super(key: key);

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shineController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _shineAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    _startAnimations();
  }
  
  void _startAnimations() {
    _slideController.forward();
    _shineController.repeat();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shineController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rediriger immédiatement vers le nouveau dialog de prix
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(); // Fermer ce dialog
      showDialog(
        context: context,
        builder: (context) => PremiumPricingDialog(
          limitationType: widget.limitationType,
          onUpgrade: widget.onUpgrade,
        ),
      );
    });
    
    // Afficher un dialog vide pendant la transition
    return const Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox.shrink(),
    );
  }

  Widget _buildHeader(LocalizationService localizationService, bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 24),
      child: Column(
        children: [
          // Icône Premium avec animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isLandscape ? 60 : 80,
                  height: isLandscape ? 60 : 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SpaceColors.starYellow.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Effet de brillance
                      AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _shineAnimation.value * 2 * math.pi,
                            child: Container(
                              width: isLandscape ? 50 : 70,
                              height: isLandscape ? 50 : 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.3),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Icône diamant
                      Icon(
                        Icons.diamond,
                        color: SpaceColors.spaceBlack,
                        size: isLandscape ? 28 : 36,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: isLandscape ? 12 : 16),
          
          // Titre principal
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
            ).createShader(bounds),
            child: Text(
              localizationService.isFrench 
                ? 'Débloquez le Potentiel Complet!'
                : 'Unlock Full Potential!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: isLandscape ? 20 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          SizedBox(height: isLandscape ? 4 : 8),
          
          // Sous-titre
          Text(
            _getLimitationMessage(localizationService),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SpaceColors.starWhiteSecondary,
              fontSize: isLandscape ? 12 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LocalizationService localizationService, PremiumManager premiumManager, bool isLandscape) {
    final benefits = premiumManager.getPremiumBenefits();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 16 : 24),
      child: Column(
        children: [
          // Titre des bénéfices
          Text(
            localizationService.isFrench ? 'Avec Premium, obtenez :' : 'With Premium, get:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SpaceColors.starWhite,
              fontWeight: FontWeight.w600,
              fontSize: isLandscape ? 14 : null,
            ),
          ),
          
          SizedBox(height: isLandscape ? 12 : 16),
          
          // Liste des bénéfices
          ...benefits.map((benefit) => _buildBenefitItem(benefit, isLandscape)),
          
          SizedBox(height: isLandscape ? 12 : 16),
          
          // Prix et offre
          Container(
            padding: EdgeInsets.all(isLandscape ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SpaceColors.nebulaPink.withOpacity(0.2),
                  SpaceColors.starYellow.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SpaceColors.starYellow.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  localizationService.isFrench ? '✨ Offre Spéciale ✨' : '✨ Special Offer ✨',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SpaceColors.starYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: isLandscape ? 12 : null,
                  ),
                ),
                SizedBox(height: isLandscape ? 4 : 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '9.99€',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhiteTertiary,
                        decoration: TextDecoration.lineThrough,
                        fontSize: isLandscape ? 10 : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4.99€',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: SpaceColors.starYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 18 : null,
                      ),
                    ),
                    Text(
                      localizationService.isFrench ? '/mois' : '/month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SpaceColors.starWhiteSecondary,
                        fontSize: isLandscape ? 11 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(PremiumBenefit benefit, bool isLandscape) {
    return Container(
      margin: EdgeInsets.only(bottom: isLandscape ? 8 : 12),
      child: Row(
        children: [
          // Icône
          Container(
            width: isLandscape ? 32 : 40,
            height: isLandscape ? 32 : 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SpaceColors.cosmicBlue, SpaceColors.nebulaPink],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                benefit.icon,
                style: TextStyle(fontSize: isLandscape ? 16 : 20),
              ),
            ),
          ),
          
          SizedBox(width: isLandscape ? 12 : 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: isLandscape ? 12 : null,
                  ),
                ),
                Text(
                  benefit.description,
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
  }

  Widget _buildActionButtons(LocalizationService localizationService, PremiumManager premiumManager, bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 24),
      child: Column(
        children: [
          // Bouton Premium
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: SpaceColors.starYellow.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _handleUpgrade(premiumManager),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.diamond,
                          color: SpaceColors.spaceBlack,
                          size: isLandscape ? 18 : 24,
                        ),
                        SizedBox(width: isLandscape ? 6 : 8),
                        Text(
                          localizationService.isFrench ? 'Obtenir Premium' : 'Get Premium',
                          style: TextStyle(
                            color: SpaceColors.spaceBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: isLandscape ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: isLandscape ? 8 : 12),
          
          // Bouton Fermer
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              localizationService.isFrench ? 'Plus tard' : 'Maybe Later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SpaceColors.starWhiteTertiary,
                fontSize: isLandscape ? 12 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLimitationMessage(LocalizationService localizationService) {
    switch (widget.limitationType) {
      case PremiumLimitationType.users:
        return localizationService.isFrench
            ? 'Vous avez atteint la limite d\'utilisateurs gratuits'
            : 'You\'ve reached the free user limit';
      case PremiumLimitationType.tasks:
        return localizationService.isFrench
            ? 'Vous avez atteint la limite de tâches gratuites'
            : 'You\'ve reached the free task limit';
      case PremiumLimitationType.progressStyles:
        return localizationService.isFrench
            ? 'Ce style est réservé aux membres Premium'
            : 'This style is exclusive to Premium members';
    }
  }

  void _handleUpgrade(PremiumManager premiumManager) async {
    // Simulation d'activation premium (pour test)
    await premiumManager.upgradeToPremiun();
    
    if (mounted) {
      Navigator.of(context).pop();
      
      // Callback si fourni
      if (widget.onUpgrade != null) {
        widget.onUpgrade!();
      }
      
      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocalizationService>(context, listen: false).isFrench
                ? '🎉 Bienvenue dans Premium!'
                : '🎉 Welcome to Premium!',
          ),
          backgroundColor: SpaceColors.galaxyGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}