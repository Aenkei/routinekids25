import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/currency_service.dart';
import 'package:dreamflow/theme.dart';

class PremiumPricingDialog extends StatefulWidget {
  final PremiumLimitationType limitationType;
  final VoidCallback? onUpgrade;

  const PremiumPricingDialog({
    Key? key,
    required this.limitationType,
    this.onUpgrade,
  }) : super(key: key);

  @override
  State<PremiumPricingDialog> createState() => _PremiumPricingDialogState();
}

class _PremiumPricingDialogState extends State<PremiumPricingDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shineController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  
  CurrencyInfo _selectedCurrency = CurrencyService.getLocalCurrency();
  PricingInfo? _selectedPricing;
  bool _showCurrencySelector = false;

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
      curve: Curves.easeOutBack,
    ));
    
    _shineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
    
    // Démarrer les animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
    
    // Initialiser avec le prix mensuel par défaut
    final options = CurrencyService.getPricingOptions(_selectedCurrency);
    _selectedPricing = options.monthly;
  }
  
  void _startAnimations() {
    _slideController.forward();
    _shineController.repeat(reverse: true);
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
    final localizationService = Provider.of<LocalizationService>(context);
    final premiumManager = Provider.of<PremiumManager>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isLandscape ? 600 : 400,
            maxHeight: isLandscape ? 500 : 700,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SpaceColors.darkMatter,
                SpaceColors.darkMatterLight,
                SpaceColors.spacePurple,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SpaceColors.nebulaPink.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.nebulaPink.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Particules animées en arrière-plan
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlesPainter(animationValue: _particleAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Contenu principal
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(localizationService, isLandscape),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildContent(localizationService, premiumManager, isLandscape),
                    ),
                  ),
                  _buildActionButtons(localizationService, premiumManager, isLandscape),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocalizationService localizationService, bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SpaceColors.nebulaPink.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: SpaceColors.starYellow.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.diamond,
                              color: SpaceColors.spaceBlack,
                              size: isLandscape ? 20 : 28,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: isLandscape ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizationService.isFrench ? 'RoutineKids Premium' : 'RoutineKids Premium',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: SpaceColors.starWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: isLandscape ? 18 : null,
                            ),
                          ),
                          Text(
                            _getLimitationMessage(localizationService),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SpaceColors.starWhiteSecondary,
                              fontSize: isLandscape ? 12 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton de sélection de devise
              GestureDetector(
                onTap: () => setState(() => _showCurrencySelector = !_showCurrencySelector),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SpaceColors.spacePurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SpaceColors.nebulaPink.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCurrency.code,
                        style: TextStyle(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: isLandscape ? 12 : 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        _showCurrencySelector ? Icons.expand_less : Icons.expand_more,
                        color: SpaceColors.starWhite,
                        size: isLandscape ? 16 : 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Sélecteur de devise
          if (_showCurrencySelector) ...[
            SizedBox(height: 12),
            _buildCurrencySelector(isLandscape),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(bool isLandscape) {
    final popularCurrencies = ['EUR', 'USD', 'GBP', 'CAD', 'AUD', 'JPY', 'CHF'];
    final currencies = CurrencyService.getAllCurrencies();
    final popular = currencies.where((c) => popularCurrencies.contains(c.code)).toList();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpaceColors.spaceBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: popular.map((currency) {
          final isSelected = currency.code == _selectedCurrency.code;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCurrency = currency;
                _showCurrencySelector = false;
                final options = CurrencyService.getPricingOptions(_selectedCurrency);
                _selectedPricing = _selectedPricing?.isLifetime == true 
                    ? options.lifetime 
                    : options.monthly;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 8 : 12,
                vertical: isLandscape ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple,
                  width: 1,
                ),
              ),
              child: Text(
                '${currency.symbol} ${currency.code}',
                style: TextStyle(
                  color: isSelected ? SpaceColors.spaceBlack : SpaceColors.starWhite,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: isLandscape ? 10 : 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(LocalizationService localizationService, PremiumManager premiumManager, bool isLandscape) {
    final options = CurrencyService.getPricingOptions(_selectedCurrency);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 16 : 24),
      child: Column(
        children: [
          // Options de prix
          _buildPricingOptions(options, localizationService, isLandscape),
          
          SizedBox(height: isLandscape ? 16 : 24),
          
          // Avantages Premium
          _buildPremiumBenefits(premiumManager, localizationService, isLandscape),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(PricingOptions options, LocalizationService localizationService, bool isLandscape) {
    return Column(
      children: [
        Text(
          localizationService.isFrench ? 'Choisissez votre forfait' : 'Choose Your Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 16 : null,
          ),
        ),
        SizedBox(height: isLandscape ? 12 : 16),
        
        // Option mensuelle
        _buildPricingCard(
          options.monthly,
          localizationService.isFrench ? 'Mensuel' : 'Monthly',
          localizationService.isFrench ? 'Facturé chaque mois' : 'Billed monthly',
          Icons.calendar_month,
          isRecommended: false,
          isLandscape: isLandscape,
        ),
        
        SizedBox(height: isLandscape ? 8 : 12),
        
        // Option à vie
        _buildPricingCard(
          options.lifetime,
          localizationService.isFrench ? 'À vie' : 'Lifetime',
          options.getSavingsMessage(localizationService.isFrench),
          Icons.diamond,
          isRecommended: true,
          isLandscape: isLandscape,
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    PricingInfo pricing,
    String title,
    String subtitle,
    IconData icon,
    {required bool isRecommended, required bool isLandscape}
  ) {
    final isSelected = _selectedPricing?.isLifetime == pricing.isLifetime;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPricing = pricing),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isLandscape ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [SpaceColors.nebulaPink.withOpacity(0.2), SpaceColors.starYellow.withOpacity(0.1)]
                : [SpaceColors.spacePurple.withOpacity(0.2), SpaceColors.cosmicBlue.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? SpaceColors.nebulaPink : SpaceColors.spacePurple.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: SpaceColors.nebulaPink.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Badge recommandé
            if (isRecommended)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 6 : 8,
                    vertical: isLandscape ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: SpaceColors.starYellow.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '⭐ POPULAIRE',
                    style: TextStyle(
                      color: SpaceColors.spaceBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 8 : 10,
                    ),
                  ),
                ),
              ),
            
            Row(
              children: [
                // Icône
                Container(
                  padding: EdgeInsets.all(isLandscape ? 8 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [SpaceColors.nebulaPink, SpaceColors.starYellow]
                          : [SpaceColors.spacePurple, SpaceColors.cosmicBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: SpaceColors.starWhite,
                    size: isLandscape ? 16 : 20,
                  ),
                ),
                
                SizedBox(width: isLandscape ? 12 : 16),
                
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 14 : null,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isRecommended ? SpaceColors.starYellow : SpaceColors.starWhiteSecondary,
                          fontSize: isLandscape ? 10 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Prix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pricing.displayPrice,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 16 : null,
                      ),
                    ),
                    Text(
                      pricing.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhiteSecondary,
                        fontSize: isLandscape ? 9 : null,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: isLandscape ? 8 : 12),
                
                // Indicateur de sélection
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isLandscape ? 16 : 20,
                  height: isLandscape ? 16 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? SpaceColors.nebulaPink : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? SpaceColors.nebulaPink : SpaceColors.starWhiteTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected ? Icon(
                    Icons.check,
                    color: SpaceColors.starWhite,
                    size: isLandscape ? 10 : 12,
                  ) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBenefits(PremiumManager premiumManager, LocalizationService localizationService, bool isLandscape) {
    final benefits = premiumManager.getPremiumBenefits();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.isFrench ? 'Avantages Premium' : 'Premium Benefits',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 14 : null,
          ),
        ),
        SizedBox(height: isLandscape ? 8 : 12),
        ...benefits.map((benefit) => _buildBenefitItem(benefit, isLandscape)),
      ],
    );
  }

  Widget _buildBenefitItem(PremiumBenefit benefit, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLandscape ? 6 : 8),
      child: Row(
        children: [
          Text(
            benefit.icon,
            style: TextStyle(fontSize: isLandscape ? 14 : 16),
          ),
          SizedBox(width: isLandscape ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          // Bouton d'achat
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
                    onPressed: _selectedPricing != null ? () => _handleUpgrade(premiumManager) : null,
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
                          _selectedPricing?.isLifetime == true ? Icons.diamond : Icons.credit_card,
                          color: SpaceColors.spaceBlack,
                          size: isLandscape ? 18 : 24,
                        ),
                        SizedBox(width: isLandscape ? 6 : 8),
                        Text(
                          _selectedPricing != null 
                              ? (_selectedPricing!.isLifetime 
                                  ? (localizationService.isFrench ? 'Acheter à vie' : 'Buy Lifetime')
                                  : (localizationService.isFrench ? 'S\'abonner' : 'Subscribe'))
                              : (localizationService.isFrench ? 'Sélectionnez un forfait' : 'Select a plan'),
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
            ? 'Ce style nécessite Premium'
            : 'This style requires Premium';
    }
  }

  void _handleUpgrade(PremiumManager premiumManager) async {
    if (_selectedPricing == null) return;
    
    // Simuler le processus d'achat (dans une vraie app, intégrer avec les stores)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: SpaceColors.darkMatter,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: SpaceColors.nebulaPink),
              SizedBox(height: 16),
              Text(
                'Traitement de votre achat...',
                style: TextStyle(color: SpaceColors.starWhite),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Simuler le délai de traitement
    await Future.delayed(const Duration(seconds: 2));
    
    // Activer Premium
    await premiumManager.upgradeToPremiun();
    
    // Fermer le dialog de traitement
    Navigator.of(context).pop();
    
    // Fermer le dialog premium
    Navigator.of(context).pop();
    
    // Callback si fourni
    widget.onUpgrade?.call();
    
    // Afficher le message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bienvenue dans Premium ! 🎉',
          style: TextStyle(color: SpaceColors.starWhite),
        ),
        backgroundColor: SpaceColors.nebulaPink,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Painter pour les particules animées en arrière-plan
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  
  ParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SpaceColors.starYellow.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Dessiner des particules flottantes
    for (int i = 0; i < 15; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.06) + 
                (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * 0.1) + (i * size.height * 0.06) + 
                (math.cos(animationValue * 2 * math.pi + i * 0.5) * 15);
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        2 + (math.sin(animationValue * 4 * math.pi + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}