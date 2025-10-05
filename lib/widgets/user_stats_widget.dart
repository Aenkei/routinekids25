import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/theme.dart';

class UserStatsWidget extends StatefulWidget {
  final User user;
  final bool isCompact;

  const UserStatsWidget({
    Key? key,
    required this.user,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<UserStatsWidget> createState() => _UserStatsWidgetState();
}

class _UserStatsWidgetState extends State<UserStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _countAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));
    
    _countController.forward();
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, DataManager>(
      builder: (context, localizationService, dataManager, child) {
        final userTasks = dataManager.tasks.where((task) => task.assignedTo == widget.user.id).toList();
        final todayTasks = userTasks.where((task) => task.isScheduledToday).toList();
        final completedToday = todayTasks.where((task) => task.isCompletedToday).length;
        
        if (widget.isCompact) {
          return _buildCompactStats(localizationService, completedToday, todayTasks.length);
        } else {
          return _buildFullStats(localizationService, userTasks, completedToday, todayTasks.length);
        }
      },
    );
  }

  Widget _buildCompactStats(LocalizationService localizationService, int completedToday, int totalToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Today's progress
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return Text(
                '${(completedToday * _countAnimation.value).round()}/${totalToday}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SpaceColors.nebulaPink,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            localizationService.today,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SpaceColors.starWhiteSecondary,
            ),
          ),
          const SizedBox(width: 12),
          
          // Streak
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: SpaceColors.starYellow,
          ),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return Text(
                '${(widget.user.currentStreak * _countAnimation.value).round()}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SpaceColors.starYellow,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullStats(LocalizationService localizationService, List<Task> userTasks, int completedToday, int totalToday) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: SpaceColors.spacePurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: SpaceColors.nebulaPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizationService.isFrench ? 'Statistiques' : 'Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.today,
                  title: localizationService.today,
                  value: '$completedToday/$totalToday',
                  subtitle: localizationService.taskCompleted,
                  color: SpaceColors.nebulaPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  title: localizationService.currentStreak,
                  value: '${widget.user.currentStreak}',
                  subtitle: localizationService.getStreakDays(widget.user.currentStreak),
                  color: SpaceColors.starYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  title: localizationService.bestStreak,
                  value: '${widget.user.longestStreak}',
                  subtitle: localizationService.getStreakDays(widget.user.longestStreak),
                  color: SpaceColors.cosmicBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  title: localizationService.totalCompleted,
                  value: '${widget.user.totalTasksCompleted}',
                  subtitle: localizationService.totalTasks,
                  color: SpaceColors.galaxyGreen,
                ),
              ),
            ],
          ),
          
          // Level progress
          const SizedBox(height: 16),
          _buildLevelProgress(localizationService),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpaceColors.darkMatterLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SpaceColors.starWhiteSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final numericValue = int.tryParse(value.split('/')[0]) ?? 0;
              final animatedValue = (numericValue * _countAnimation.value).round();
              final displayValue = value.contains('/') 
                  ? '$animatedValue/${value.split('/')[1]}'
                  : animatedValue.toString();
              
              return Text(
                displayValue,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SpaceColors.starWhiteTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(LocalizationService localizationService) {
    final level = widget.user.level;
    final progress = widget.user.progressToNextLevel;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SpaceColors.spacePurple.withOpacity(0.3),
            SpaceColors.cosmicBlue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.military_tech,
                size: 16,
                color: SpaceColors.starYellow,
              ),
              const SizedBox(width: 6),
              Text(
                '${localizationService.level} $level',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceColors.starWhiteSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _countAnimation.value,
                backgroundColor: SpaceColors.darkMatter,
                valueColor: AlwaysStoppedAnimation<Color>(SpaceColors.starYellow),
                minHeight: 6,
              );
            },
          ),
        ],
      ),
    );
  }
}