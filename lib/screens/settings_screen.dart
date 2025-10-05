import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/widgets/add_user_dialog.dart';
import 'package:dreamflow/widgets/add_task_dialog.dart';
import 'package:dreamflow/widgets/time_periods_dialog.dart';
import 'package:dreamflow/widgets/language_selector_dialog.dart';
import 'package:dreamflow/widgets/progress_style_dialog.dart';
import 'package:dreamflow/widgets/premium_status_widget.dart';
import 'package:dreamflow/screens/user_task_management_screen.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceColors.spaceBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: SpaceColors.spaceGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Consumer2<DataManager, LocalizationService>(
                          builder: (context, dataManager, localizationService, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const PremiumStatusWidget(),
                                _buildLanguageSection(context, dataManager, localizationService),
                                const SizedBox(height: 32),
                                _buildTimePeriodsSection(context, dataManager, localizationService),
                                const SizedBox(height: 32),
                                _buildUserManagement(context, dataManager, localizationService),
                                const SizedBox(height: 32),
                                _buildTaskManagement(context, dataManager, localizationService),
                                const SizedBox(height: 32),
                                _buildDataManagement(context, dataManager, localizationService),
                                const SizedBox(height: 32),
                                _buildAboutSection(context, localizationService),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _slideController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SpaceColors.darkMatter.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: SpaceColors.starWhite,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  localizationService.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.appSettings,
          localizationService.languageSettings,
          Icons.settings,
          localizationService,
        ),
        
        _buildActionCard(
          title: localizationService.language,
          subtitle: '${localizationService.currentLanguage == AppLanguage.english ? '🇺🇸' : '🇫🇷'} ${localizationService.languageName}',
          icon: Icons.language,
          onTap: () => _showLanguageDialog(context),
          gradientColor: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildActionCard(
          title: localizationService.isFrench ? 'Styles de Progression' : 'Progress Styles',
          subtitle: localizationService.isFrench 
              ? '${_getProgressStyleName(dataManager.progressRingStyle)} ⚡'
              : '${_getProgressStyleName(dataManager.progressRingStyle)} ⚡',
          icon: Icons.auto_awesome,
          onTap: () => _showProgressStyleDialog(context),
          gradientColor: const LinearGradient(
            colors: [SpaceColors.nebulaPink, SpaceColors.spacePurple],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, IconData icon, LocalizationService localizationService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: SpaceColors.nebulaGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhiteSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.userManagement,
          localizationService.isFrench ? 'Ajouter, modifier et gérer les membres de la famille' : 'Add, edit, and manage family members',
          Icons.family_restroom,
          localizationService,
        ),
        
        // Add user button
        _buildActionCard(
          title: localizationService.addNewCrewMember,
          subtitle: localizationService.recruitNewAstronaut,
          icon: Icons.person_add,
          onTap: () => _showAddUserDialog(context),
          gradientColor: SpaceColors.nebulaGradient,
        ),
        
        const SizedBox(height: 16),
        
        // Users list
        if (dataManager.users.isNotEmpty) ...[
          ...dataManager.users.map((user) => _buildUserCard(context, user, dataManager, localizationService)),
        ] else ...[
          _buildEmptyStateCard(
            localizationService.isFrench ? 'Aucun membre d\'équipage pour le moment' : 'No crew members yet',
            localizationService.isFrench ? 'Ajoutez votre premier astronaute pour commencer la mission!' : 'Add your first astronaut to begin the mission!',
            Icons.person,
          ),
        ],
      ],
    );
  }

  Widget _buildTimePeriodsSection(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.timePeriods,
          localizationService.customizeTimeSettings,
          Icons.schedule,
          localizationService,
        ),
        const SizedBox(height: 16),
        
        _buildActionCard(
          title: localizationService.timePeriods,
          subtitle: '${localizationService.morning}: ${dataManager.morningStartHour}:00-${dataManager.morningEndHour}:00 • ${localizationService.evening}: ${dataManager.eveningStartHour}:00-${dataManager.eveningEndHour}:00',
          icon: Icons.access_time,
          onTap: () => _showTimePeriodsDialog(context, dataManager),
          gradientColor: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskManagement(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    final tasksByCategory = <String, List<Task>>{};
    for (final task in dataManager.tasks) {
      tasksByCategory.putIfAbsent(task.category, () => []).add(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.taskManagement,
          localizationService.isFrench ? 'Gérer les objectifs quotidiens de votre famille' : 'Manage your family\'s daily objectives',
          Icons.rocket_launch,
          localizationService,
        ),
        const SizedBox(height: 16),
        
        // Add new task button
        _buildActionCard(
          title: localizationService.isFrench ? 'Créer une nouvelle mission' : 'Create New Mission',
          subtitle: localizationService.isFrench ? 'Concevoir une tâche personnalisée pour votre équipe' : 'Design a custom task for your crew',
          icon: Icons.add_task,
          onTap: () => _showAddTaskDialog(context),
          gradientColor: const LinearGradient(
            colors: [Color(0xFF4fc3f7), Color(0xFF29b6f6)],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Existing tasks by category
        if (tasksByCategory.isEmpty)
          _buildEmptyStateCard(
            localizationService.isFrench ? 'Aucune mission active' : 'No Active Missions',
            localizationService.isFrench ? 'Créez votre première tâche pour commencer l\'aventure' : 'Create your first task to begin the adventure',
            Icons.explore,
          )
        else
          ...tasksByCategory.entries.map((entry) => 
            _buildTaskCategoryCard(context, entry.key, entry.value, dataManager, localizationService)
          ),
      ],
    );
  }

  Widget _buildDataManagement(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.dataManagement,
          localizationService.isFrench ? 'Sauvegarder et réinitialiser les données de votre station spatiale' : 'Backup and reset your space station data',
          Icons.storage,
          localizationService,
        ),
        
        _buildActionCard(
          title: localizationService.resetProgress,
          subtitle: localizationService.isFrench ? 'Effacer toutes les données de mission et repartir à zéro' : 'Clear all mission data and start fresh',
          icon: Icons.refresh,
          onTap: () => _confirmResetProgress(context, dataManager, localizationService),
          gradientColor: const LinearGradient(
            colors: [Color(0xFFE57373), Color(0xFFEF5350)],
          ),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          localizationService.about,
          localizationService.appInfo,
          Icons.info,
          localizationService,
        ),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: SpaceColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizationService.appVersion,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SpaceColors.starWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizationService.appDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SpaceColors.nebulaPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizationService.appFeatures,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceColors.starWhiteSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizationService.appMadeWith,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceColors.starYellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎨 ${localizationService.customizableThemes}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🎉 ${localizationService.funAnimations}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🔒 ${localizationService.secureAccess}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📆 ${localizationService.routineManagement}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradientColor,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradientColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : SpaceColors.nebulaPink.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: SpaceColors.starWhite,
              size: 28,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: SpaceColors.starWhite,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user, DataManager dataManager, LocalizationService localizationService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SpaceColors.nebulaGradient,
              border: Border.all(
                color: SpaceColors.starWhite.withOpacity(0.3),
              ),
            ),
            child: ClipOval(
              child: user.profilePicture != null
                  ? Image.memory(
                      user.profilePicture!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      color: SpaceColors.starWhite,
                      size: 24,
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: SpaceColors.starYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${localizationService.level} ${user.level}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.starWhiteSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (user.currentStreak > 0) ...[
                      Icon(
                        Icons.local_fire_department,
                        color: SpaceColors.starYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        localizationService.getStreakDays(user.currentStreak),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Task management button
                _buildTaskManagementButton(context, user, dataManager),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditUserDialog(context, user),
                icon: const Icon(Icons.edit, color: SpaceColors.cosmicBlue),
              ),
              IconButton(
                onPressed: () => _confirmDeleteUser(context, user.id, dataManager),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCategoryCard(BuildContext context, String category, 
                               List<Task> tasks, DataManager dataManager, LocalizationService localizationService) {
    final categoryData = localizationService.taskCategories
        .firstWhere((cat) => cat['name'] == category || cat['englishName'] == category, 
                   orElse: () => localizationService.taskCategories.first);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryData['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryData['icon'],
                    color: categoryData['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizationService.getCategoryName(category),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        localizationService.getTasksHeader(tasks.length),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Available Tasks style display - like in home page
            if (tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SpaceColors.spaceBlack.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: SpaceColors.starWhiteSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizationService.isFrench ? 'Aucune tâche dans cette catégorie' : 'No tasks in this category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 44, // Hauteur fixe pour les chips
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return GestureDetector(
                      onTap: () => _showEditTaskDialog(context, task),
                      child: _buildTaskChip(task),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskChip(Task task) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                task.iconColor.withOpacity(0.8),
                task.iconColor.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.iconColor.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: task.iconColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                task.icon,
                color: SpaceColors.starWhite,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                localizationService.getTaskTitle(task.title),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceColors.starWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, DataManager dataManager) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SpaceColors.darkMatterLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                task.icon,
                color: task.iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizationService.getTaskTitle(task.title),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        localizationService.getTaskDescription(task.description),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: task.iconColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            localizationService.getCategoryName(task.category),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: task.iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (task.assignedTo != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SpaceColors.galaxyGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              localizationService.assigned,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SpaceColors.galaxyGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditTaskDialog(context, task),
                    icon: const Icon(Icons.edit, color: SpaceColors.cosmicBlue, size: 18),
                  ),
                  IconButton(
                    onPressed: () => _confirmDeleteTask(context, task.id, dataManager),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: SpaceColors.starWhiteSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SpaceColors.starWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SpaceColors.starWhiteSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(userToEdit: user),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AddTaskDialog(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            AddTaskDialog(taskToEdit: task),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId, DataManager dataManager) {
    final localizationService = context.read<LocalizationService>();
    final user = dataManager.users.firstWhere((u) => u.id == userId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.deleteUser),
        content: Text(localizationService.getUserDeleteConfirmation(user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizationService.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              dataManager.deleteUser(userId);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizationService.userDeleted),
                  backgroundColor: SpaceColors.nebulaPink,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(localizationService.delete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, String taskId, DataManager dataManager) {
    final localizationService = context.read<LocalizationService>();
    final task = dataManager.tasks.firstWhere((t) => t.id == taskId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.deleteTask),
        content: Text(localizationService.getTaskDeleteConfirmation(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizationService.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              dataManager.deleteTask(taskId);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizationService.taskDeleted),
                  backgroundColor: SpaceColors.nebulaPink,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(localizationService.delete),
          ),
        ],
      ),
    );
  }

  void _confirmResetProgress(BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.resetProgress),
        content: Text(localizationService.resetProgressConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizationService.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              dataManager.resetProgress();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizationService.progressReset),
                  backgroundColor: SpaceColors.nebulaPink,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(localizationService.isFrench ? 'Réinitialiser' : 'Reset'),
          ),
        ],
      ),
    );
  }

  void _showTimePeriodsDialog(BuildContext context, DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) => TimePeriodsDialog(dataManager: dataManager),
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }
  
  void _showProgressStyleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgressStyleDialog(),
    );
  }
  
  String _getProgressStyleName(String style) {
    switch (style) {
      case 'neon':
        return '⚡ Néon Électrique';
      case 'rainbow':
        return '🌈 Arc-en-ciel Cosmique';
      case 'crystal':
        return '💎 Cristal Prismatique';
      default:
        return '⚡ Néon Électrique';
    }
  }

  Widget _buildTaskManagementButton(BuildContext context, User user, DataManager dataManager) {
    final userTasks = dataManager.tasks.where((task) => task.assignedTo == user.id).toList();
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UserTaskManagementScreen(user: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SpaceColors.cosmicBlue.withOpacity(0.6),
              SpaceColors.spacePurple.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SpaceColors.spacePurple.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: SpaceColors.cosmicBlue.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_ind,
              color: SpaceColors.starWhite,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '${context.read<LocalizationService>().taskManagement} (${userTasks.length})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              color: SpaceColors.starWhite,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}