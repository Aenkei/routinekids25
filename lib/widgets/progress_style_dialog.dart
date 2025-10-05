import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/widgets/modern_progress_ring.dart';
import 'package:dreamflow/widgets/premium_pricing_dialog.dart';
import 'package:dreamflow/theme.dart';

class ProgressStyleDialog extends StatefulWidget {
  const ProgressStyleDialog({Key? key}) : super(key: key);

  @override
  State<ProgressStyleDialog> createState() => _ProgressStyleDialogState();
}

class _ProgressStyleDialogState extends State<ProgressStyleDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String _selectedStyle = 'rainbow'; // Default to Rainbow (free theme)
  String _tempSelectedStyle = 'rainbow';

  @override
  void initState() {
    super.initState();
    
    // Initialize with current style
    final dataManager = Provider.of<DataManager>(context, listen: false);
    _selectedStyle = dataManager.progressRingStyle;
    _tempSelectedStyle = _selectedStyle;
    
    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _selectStyle(String style) {
    final premiumManager = Provider.of<PremiumManager>(context, listen: false);
    
    // Vérifier si le style nécessite premium
    if (!premiumManager.canUseProgressStyle(style)) {
      _showPremiumDialog();
      return;
    }
    
    setState(() {
      _tempSelectedStyle = style;
    });
  }
  
  void _confirmSelection() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    dataManager.updateProgressRingStyle(_tempSelectedStyle);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getStyleSuccessMessage(_tempSelectedStyle)),
        backgroundColor: SpaceColors.galaxyGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    Navigator.of(context).pop();
  }

  String _getStyleSuccessMessage(String style) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    switch (style) {
      case 'neon':
        return localizationService.isFrench 
          ? '⚡ Mode Néon Électrique activé!'
          : '⚡ Electric Neon mode activated!';
      case 'rainbow':
        return localizationService.isFrench 
          ? '🌈 Mode Arc-en-ciel Cosmique activé!'
          : '🌈 Cosmic Rainbow mode activated!';
      case 'crystal':
        return localizationService.isFrench 
          ? '💎 Mode Cristal Prismatique activé!'
          : '💎 Prismatic Crystal mode activated!';
      default:
        return localizationService.isFrench 
          ? 'Style de progression mis à jour!'
          : 'Progress style updated!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
        ),
        backgroundColor: SpaceColors.darkMatter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: isLandscape ? mediaQuery.size.height * 0.85 : double.infinity,
            maxWidth: isLandscape ? mediaQuery.size.width * 0.85 : double.infinity,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(isLandscape ? 16 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(localizationService),
                  SizedBox(height: isLandscape ? 6 : 24),
                  _buildStyleOptions(localizationService),
                  SizedBox(height: isLandscape ? 6 : 24),
                  _buildConfirmButton(localizationService),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocalizationService localizationService) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isLandscape ? 8 : 16),
          decoration: BoxDecoration(
            gradient: SpaceColors.nebulaGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.palette,
            color: SpaceColors.starWhite,
            size: isLandscape ? 16 : 32,
          ),
        ),
        SizedBox(height: isLandscape ? 4 : 16),
        Text(
          localizationService.isFrench ? 'Styles de Progression' : 'Progress Styles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 12 : null,
          ),
        ),
        SizedBox(height: isLandscape ? 2 : 8),
        Text(
          localizationService.isFrench 
            ? 'Choisissez votre style visuel préféré'
            : 'Choose your preferred visual style',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SpaceColors.starWhiteSecondary,
            fontSize: isLandscape ? 8 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStyleOptions(LocalizationService localizationService) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 4.0 : 16.0,
        vertical: isLandscape ? 3.0 : 12.0,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: isLandscape ? 3.0 : 8.0,
        mainAxisSpacing: isLandscape ? 3.0 : 8.0,
        children: [
          _buildStyleOption('rainbow', '🌈', 'Arc-en-ciel', ProgressRingStyle.cosmicRainbow),
          _buildStyleOption('neon', '⚡', 'Néon', ProgressRingStyle.neonGlow, isLocked: !context.read<PremiumManager>().isPremium),
          _buildStyleOption('crystal', '💎', 'Cristal', ProgressRingStyle.crystalPrism, isLocked: !context.read<PremiumManager>().isPremium),
        ],
      ),
    );
  }

  Widget _buildStyleOption(
    String styleKey,
    String emoji,
    String title,
    ProgressRingStyle ringStyle, {
    bool isLocked = false,
    bool isLandscape = false,
  }) {
    final isSelected = _tempSelectedStyle == styleKey;
    
    // Responsive sizing - Plus compact pour paysage
    final cardPadding = isLandscape ? 6.0 : 16.0;
    final emojiSize = isLandscape ? 12.0 : 32.0;
    final ringSize = isLandscape ? 50.0 : 60.0; // AGRANDIE de 40 à 50
    final childSize = isLandscape ? 25.0 : 30.0; // AGRANDIE de 20 à 25
    final iconSize = childSize * 0.5;
    final spacingBetween = isLandscape ? 1.0 : 8.0;
    final titleFontSize = isLandscape ? 7.0 : 12.0;
    final lockIconSize = isLandscape ? 8.0 : 20.0;
    final premiumFontSize = isLandscape ? 5.0 : 8.0;
    
    return GestureDetector(
      onTap: isLocked ? () => _showPremiumDialog() : () => _selectStyle(styleKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: isSelected && !isLocked
              ? const LinearGradient(
                  colors: [SpaceColors.nebulaPink, SpaceColors.starYellow],
                )
              : null,
          color: isSelected && !isLocked ? null : SpaceColors.darkMatter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && !isLocked
                ? SpaceColors.starYellow
                : SpaceColors.spacePurple.withOpacity(0.3),
            width: isSelected && !isLocked ? 2 : 1,
          ),
          boxShadow: isSelected && !isLocked
              ? [
                  BoxShadow(
                    color: SpaceColors.starYellow.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Contenu principal
            Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji
                  Text(
                    emoji,
                    style: TextStyle(fontSize: emojiSize),
                  ),
                  
                  SizedBox(height: spacingBetween),
                  
                  // Preview Ring - Now 70% of card as requested
                  ModernProgressRing(
                    totalTasks: 8,
                    completedTasks: 6,
                    size: ringSize,
                    style: ringStyle,
                    child: Container(
                      width: childSize,
                      height: childSize,
                      decoration: const BoxDecoration(
                        color: SpaceColors.cosmicBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: SpaceColors.starWhite,
                        size: iconSize,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: spacingBetween),
                  
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected && !isLocked ? SpaceColors.spaceBlack : SpaceColors.starWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: titleFontSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Verrou premium
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isLandscape ? 6 : 8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          color: SpaceColors.spaceBlack,
                          size: lockIconSize,
                        ),
                      ),
                      SizedBox(height: isLandscape ? 0.5 : 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 2.0 : 6.0, 
                          vertical: isLandscape ? 0.5 : 2.0
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [SpaceColors.starYellow, SpaceColors.nebulaPink],
                          ),
                          borderRadius: BorderRadius.circular(isLandscape ? 3.0 : 8.0),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SpaceColors.spaceBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: premiumFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(LocalizationService localizationService) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 4.0 : 16.0),
      child: ElevatedButton.icon(
        onPressed: _confirmSelection,
        icon: Icon(
          Icons.check,
          color: SpaceColors.starWhite,
          size: isLandscape ? 12.0 : 20.0,
        ),
        label: Text(
          'Appliquer le Style',
          style: TextStyle(
            color: SpaceColors.starWhite,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 10.0 : 16.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: SpaceColors.nebulaPink,
          padding: EdgeInsets.symmetric(
            vertical: isLandscape ? 8.0 : 16.0,
            horizontal: isLandscape ? 12.0 : 24.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLandscape ? 6.0 : 12.0),
          ),
        ),
      ),
    );
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumPricingDialog(
        limitationType: PremiumLimitationType.progressStyles,
      ),
    );
  }
}