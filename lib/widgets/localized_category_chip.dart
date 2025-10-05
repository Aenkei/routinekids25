import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class LocalizedCategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const LocalizedCategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final localizedName = localizationService.getCategoryName(category.englishName);
        
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16, 
              vertical: isCompact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? SpaceColors.nebulaGradient 
                  : null,
              color: isSelected 
                  ? null 
                  : SpaceColors.darkMatter,
              borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
              border: Border.all(
                color: isSelected
                    ? SpaceColors.nebulaPink.withOpacity(0.6)
                    : SpaceColors.spacePurple.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: SpaceColors.nebulaPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? SpaceColors.starWhite : category.color,
                  size: isCompact ? 16 : 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    localizedName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? SpaceColors.starWhite 
                          : SpaceColors.starWhiteSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isCompact ? 12 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension for displaying localized category names
extension LocalizedTaskCategory on TaskCategory {
  Widget toChip(
    LocalizationService localizationService, {
    bool isSelected = false,
    VoidCallback? onTap,
    bool isCompact = false,
  }) {
    return LocalizedCategoryChip(
      category: this,
      isSelected: isSelected,
      onTap: onTap ?? () {},
      isCompact: isCompact,
    );
  }
  
  String getLocalizedName(LocalizationService localizationService) {
    return localizationService.getCategoryName(englishName);
  }
}