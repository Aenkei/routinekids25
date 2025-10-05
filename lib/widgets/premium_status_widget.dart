import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class PremiumStatusWidget extends StatefulWidget {
  const PremiumStatusWidget({Key? key}) : super(key: key);

  @override
  State<PremiumStatusWidget> createState() => _PremiumStatusWidgetState();
}

class _PremiumStatusWidgetState extends State<PremiumStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final premiumManager = Provider.of<PremiumManager>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: premiumManager.isPremium
            ? const LinearGradient(
                colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
              )
            : LinearGradient(
                colors: [
                  SpaceColors.spacePurple.withOpacity(0.3),
                  SpaceColors.cosmicBlue.withOpacity(0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: premiumManager.isPremium
              ? SpaceColors.starYellow.withOpacity(0.5)
              : SpaceColors.spacePurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          if (premiumManager.isPremium)
            BoxShadow(
              color: SpaceColors.starYellow.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _togglePremiumStatus(premiumManager, localizationService),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: premiumManager.isPremium 
                ? _buildPremiumStatus(localizationService)
                : _buildFreeStatus(localizationService),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumStatus(LocalizationService localizationService) {
    return Row(
      children: [
        // Icône Premium animée
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SpaceColors.spaceBlack.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.diamond,
                  color: SpaceColors.spaceBlack,
                  size: 28,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 16),
        
        // Informations Premium
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    localizationService.isFrench ? 'Statut Premium' : 'Premium Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SpaceColors.spaceBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SpaceColors.galaxyGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      localizationService.isFrench ? 'ACTIF' : 'ACTIVE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.spaceBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                localizationService.isFrench 
                    ? 'Accès complet à toutes les fonctionnalités'
                    : 'Full access to all features',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceColors.spaceBlack.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        
        // Indicateur de test
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: SpaceColors.spaceBlack.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            localizationService.isFrench ? 'TEST' : 'TEST',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SpaceColors.spaceBlack,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreeStatus(LocalizationService localizationService) {
    return Row(
      children: [
        // Icône Gratuit
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SpaceColors.spacePurple.withOpacity(0.3),
                SpaceColors.cosmicBlue.withOpacity(0.3),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: SpaceColors.starWhiteSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.star_border,
            color: SpaceColors.starWhiteSecondary,
            size: 28,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Informations Gratuit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    localizationService.isFrench ? 'Version Gratuite' : 'Free Version',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SpaceColors.starWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SpaceColors.cosmicBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SpaceColors.cosmicBlue.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      localizationService.isFrench ? 'LIBRE' : 'FREE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                localizationService.isFrench 
                    ? 'Fonctionnalités limitées • Toucher pour Premium'
                    : 'Limited features • Tap for Premium',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceColors.starWhiteSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Icône d'action
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.upgrade,
            color: SpaceColors.spaceBlack,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _togglePremiumStatus(PremiumManager premiumManager, LocalizationService localizationService) async {
    // Animation de feedback
    await _pulseController.forward();
    _pulseController.reset();
    _pulseController.repeat(reverse: true);
    
    // Toggle du statut
    await premiumManager.togglePremiumStatus();
    
    // Message de feedback
    final message = premiumManager.isPremium
        ? (localizationService.isFrench 
            ? '🎉 Premium activé (mode test)' 
            : '🎉 Premium activated (test mode)')
        : (localizationService.isFrench 
            ? '📱 Retour en mode gratuit' 
            : '📱 Back to free mode');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: premiumManager.isPremium 
              ? SpaceColors.galaxyGreen 
              : SpaceColors.cosmicBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Widget compact pour afficher le statut premium dans d'autres écrans
class CompactPremiumIndicator extends StatelessWidget {
  const CompactPremiumIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final premiumManager = Provider.of<PremiumManager>(context);
    final localizationService = Provider.of<LocalizationService>(context);

    if (!premiumManager.isPremium) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SpaceColors.starYellow.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond,
            color: SpaceColors.spaceBlack,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            localizationService.isFrench ? 'PREMIUM' : 'PREMIUM',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SpaceColors.spaceBlack,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}