import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({Key? key}) : super(key: key);

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _selectLanguage(AppLanguage language) {
    final dataManager = context.read<DataManager>();
    final localizationService = context.read<LocalizationService>();
    
    dataManager.updateLanguage(language);
    localizationService.setLanguage(language);
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizationService.isFrench ? 
            'Langue changée vers ${localizationService.languageName}!' :
            'Language changed to ${localizationService.languageName}!',
          style: const TextStyle(color: SpaceColors.starWhite),
        ),
        backgroundColor: SpaceColors.nebulaPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataManager, LocalizationService>(
      builder: (context, dataManager, localizationService, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: SpaceColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: SpaceColors.spacePurple.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SpaceColors.spacePurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(localizationService),
                  _buildLanguageOptions(dataManager, localizationService),
                  _buildCloseButton(localizationService),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: SpaceColors.nebulaGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpaceColors.starWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.language,
              color: SpaceColors.starWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizationService.languageSettings,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizationService.selectLanguage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhite.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOptions(DataManager dataManager, LocalizationService localizationService) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildLanguageOption(
            title: 'English',
            subtitle: 'Default language',
            flag: '🇺🇸',
            language: AppLanguage.english,
            isSelected: dataManager.selectedLanguage == AppLanguage.english,
            onTap: () => _selectLanguage(AppLanguage.english),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(
            title: 'Français',
            subtitle: 'Langue française',
            flag: '🇫🇷',
            language: AppLanguage.french,
            isSelected: dataManager.selectedLanguage == AppLanguage.french,
            onTap: () => _selectLanguage(AppLanguage.french),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String flag,
    required AppLanguage language,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? SpaceColors.spacePurple.withOpacity(0.3)
            : SpaceColors.spaceBlackLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? SpaceColors.nebulaPink 
              : SpaceColors.spacePurple.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: SpaceColors.darkMatter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SpaceColors.starWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SpaceColors.nebulaPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: SpaceColors.starWhite,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(LocalizationService localizationService) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: SpaceColors.spacePurple,
            foregroundColor: SpaceColors.starWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            localizationService.close,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}