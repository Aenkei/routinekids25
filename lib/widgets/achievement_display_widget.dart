import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

class AchievementDisplayWidget extends StatefulWidget {
  final User user;
  final bool isCompact;

  const AchievementDisplayWidget({
    Key? key,
    required this.user,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<AchievementDisplayWidget> createState() => _AchievementDisplayWidgetState();
}

class _AchievementDisplayWidgetState extends State<AchievementDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _shineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final userAchievements = widget.user.achievements;
        
        if (userAchievements.isEmpty) {
          return _buildEmptyState(localizationService);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isCompact) ...[
              Text(
                '${localizationService.achievements} (${userAchievements.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            if (widget.isCompact)
              _buildCompactView(userAchievements, localizationService)
            else
              _buildFullView(userAchievements, localizationService),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpaceColors.darkMatter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 32,
            color: SpaceColors.starWhiteTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            localizationService.noAchievements,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SpaceColors.starWhiteTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView(List<String> userAchievements, LocalizationService localizationService) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: userAchievements.length,
        itemBuilder: (context, index) {
          final achievementId = userAchievements[index];
          final achievement = Achievement.getById(achievementId);
          
          if (achievement == null) return const SizedBox.shrink();
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildAchievementBadge(achievement, localizationService, true),
          );
        },
      ),
    );
  }

  Widget _buildFullView(List<String> userAchievements, LocalizationService localizationService) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: userAchievements.map((achievementId) {
        final achievement = Achievement.getById(achievementId);
        if (achievement == null) return const SizedBox.shrink();
        
        return _buildAchievementBadge(achievement, localizationService, false);
      }).toList(),
    );
  }

  Widget _buildAchievementBadge(Achievement achievement, LocalizationService localizationService, bool isCompact) {
    final localizedTitle = localizationService.getAchievementTitle(achievement.englishTitle);
    final localizedDescription = localizationService.getAchievementDescription(achievement.englishDescription);
    
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(isCompact ? 8 : 12),
          decoration: BoxDecoration(
            gradient: achievement.isRare 
                ? LinearGradient(
                    colors: [
                      SpaceColors.starYellow.withOpacity(0.8),
                      SpaceColors.nebulaPink.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : SpaceColors.nebulaGradient,
            borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: (achievement.isRare ? SpaceColors.starYellow : SpaceColors.nebulaPink)
                    .withOpacity(0.3 + (_shineAnimation.value * 0.2)),
                blurRadius: 8 + (_shineAnimation.value * 4),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isCompact 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      achievement.icon,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      localizedTitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      achievement.icon,
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizedTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizedDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhite.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// Extension to provide individual achievement display
extension AchievementWidget on Achievement {
  Widget toWidget(LocalizationService localizationService, {bool isCompact = false}) {
    final localizedTitle = localizationService.getAchievementTitle(englishTitle);
    final localizedDescription = localizationService.getAchievementDescription(englishDescription);
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        gradient: isRare 
            ? LinearGradient(
                colors: [
                  SpaceColors.starYellow.withOpacity(0.8),
                  SpaceColors.nebulaPink.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : SpaceColors.nebulaGradient,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: (isRare ? SpaceColors.starYellow : SpaceColors.nebulaPink)
                .withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  localizedTitle,
                  style: TextStyle(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  localizedTitle,
                  style: TextStyle(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  localizedDescription,
                  style: TextStyle(
                    color: SpaceColors.starWhite.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}