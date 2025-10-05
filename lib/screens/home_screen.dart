import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/widgets/user_dashboard_widget.dart';
import 'package:dreamflow/widgets/modern_task_card.dart';
import 'package:dreamflow/widgets/starry_background.dart';
import 'package:dreamflow/widgets/add_user_dialog.dart';
import 'package:dreamflow/widgets/add_task_dialog.dart';
import 'package:dreamflow/widgets/debug_task_assignment_widget.dart';
import 'package:dreamflow/widgets/parental_control_dialog.dart';
import 'package:dreamflow/widgets/onboarding_widget.dart';
import 'package:dreamflow/screens/settings_screen.dart';
import 'package:dreamflow/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  
  DayOfWeek get _selectedDay => Task.today;
  final ScrollController _scrollController = ScrollController();
  
  // Time period selection
  String _selectedTimePeriod = 'current'; // 'current', 'morning', 'evening'

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    ));
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));
    
    _headerController.forward();
    
    // Set initial time period based on current time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialTimePeriod();
    });
  }

  void _setInitialTimePeriod() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final hour = now.hour;
      
      if (mounted) {
        setState(() {
          if (hour >= 7 && hour < 12) {
            _selectedTimePeriod = 'morning';
          } else if (hour >= 12 && hour < 21) {
            _selectedTimePeriod = 'evening';
          } else {
            _selectedTimePeriod = 'current';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceColors.spaceBlack,
      body: StarryBackground(
        numberOfStars: 80,
        child: SafeArea(
          child: Consumer<DataManager>(
            builder: (context, dataManager, child) {
              return Column(
                children: [
                  _buildHeader(context, dataManager),
                  Expanded(
                    child: _buildMainContent(context, dataManager),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DataManager dataManager) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: SlideTransition(
            position: _headerSlideAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RoutineKids',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGreetingMessage(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: SpaceColors.starWhiteSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      // Time period toggle
                      _buildTimeOfDayToggle(),
                      
                      const SizedBox(width: 16),
                      
                      // Modern digital clock
                      _buildModernDigitalClock(),
                      
                      const SizedBox(width: 16),
                      
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ParentalControlDialog(
                              onSuccess: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const SettingsScreen(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
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
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: SpaceColors.cardGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: SpaceColors.spacePurple.withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SpaceColors.spacePurple.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: SpaceColors.starWhite,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildMainContent(BuildContext context, DataManager dataManager) {
    final users = dataManager.users;
    
    // Show onboarding only if no users AND language has been selected
    final bool languageSelected = dataManager.prefs.getBool('language_selected') ?? false;
    if (users.isEmpty && languageSelected) {
      return const OnboardingWidget();
    }
    
    // If no users and language not selected, this shouldn't happen as we redirect to language screen
    // But just in case, show empty container
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // User dashboards
              ...users.map((user) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: UserDashboardWidget(
                  key: ValueKey('${user.id}_${_selectedDay}_${_selectedTimePeriod}_${dataManager.tasks.length}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}'),
                  user: user,
                  currentDay: _selectedDay,
                  isExpanded: true,
                  selectedTimePeriod: _selectedTimePeriod,
                  onExpandToggle: (expanded) {},
                ),
              )).toList(),
              
              // Available Tasks Section
              _buildAvailableTasksSection(context, dataManager),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableTasksSection(BuildContext context, DataManager dataManager) {
    return Consumer2<LocalizationService, DataManager>(
      builder: (context, localizationService, dataManager, child) {
        // Get ALL unassigned tasks, not just those for the selected day
        final availableTasks = dataManager.getAllUnassignedTasks();
        final filteredTasks = availableTasks.where((task) {
          if (_selectedTimePeriod == 'current') return true;
          if (_selectedTimePeriod == 'morning') {
            return task.timePeriod == TimePeriod.morning || task.timePeriod == TimePeriod.both;
          }
          if (_selectedTimePeriod == 'evening') {
            return task.timePeriod == TimePeriod.evening || task.timePeriod == TimePeriod.both;
          }
          return true;
        }).toList();
        
        if (filteredTasks.isEmpty && dataManager.tasks.isNotEmpty) {
          return const SizedBox.shrink();
        }
        
        if (filteredTasks.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(24),
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
                  Icons.assignment_add,
                  size: 48,
                  color: SpaceColors.nebulaPink,
                ),
                const SizedBox(height: 16),
                Text(
                  localizationService.isFrench ? 'Aucune tâche à assigner' : 'No tasks to assign',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SpaceColors.starWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizationService.isFrench 
                    ? 'Créez des tâches pour commencer à les assigner aux utilisateurs'
                    : 'Create tasks to start assigning them to users',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhiteSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add, color: SpaceColors.starWhite),
                  label: Text(
                    localizationService.isFrench ? 'Créer une tâche' : 'Create Task',
                    style: const TextStyle(color: SpaceColors.starWhite),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpaceColors.nebulaPink,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          margin: const EdgeInsets.only(top: 16),
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
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: SpaceColors.starYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizationService.assignTasks,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SpaceColors.starWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          localizationService.isFrench 
                            ? 'Touchez une tâche pour l\'assigner à un utilisateur'
                            : 'Tap any task to assign it to a user',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SpaceColors.starWhiteSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SpaceColors.starYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredTasks.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpaceColors.spaceBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredTasks.map((task) => _buildAvailableTaskChip(task, context, dataManager, localizationService)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailableTaskChip(Task task, BuildContext context, DataManager dataManager, LocalizationService localizationService) {
    return GestureDetector(
      onTap: () => _showTaskAssignmentDialog(context, task, dataManager, localizationService),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: SpaceColors.darkMatterLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.iconColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: task.iconColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            task.customImage != null
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.iconColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.memory(
                        task.customImage!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Icon(
                    task.icon,
                    color: task.iconColor,
                    size: 20,
                  ),
            const SizedBox(width: 8),
            Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SpaceColors.starWhite,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _getTimePeriodIcon(task.timePeriod),
              color: SpaceColors.starWhiteSecondary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              color: SpaceColors.nebulaPink,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTimePeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.morning:
        return Icons.wb_sunny;
      case TimePeriod.evening:
        return Icons.nightlight_round;
      case TimePeriod.both:
        return Icons.all_inclusive;
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  Widget _buildTimeOfDayToggle() {
    return Consumer2<DataManager, LocalizationService>(
      builder: (context, dataManager, localizationService, child) {
        final isMorning = dataManager.isCurrentlyMorning();
        final isEvening = dataManager.isCurrentlyEvening();
        
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: SpaceColors.cardGradient,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: SpaceColors.spacePurple.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.spacePurple.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimePeriod = _selectedTimePeriod == 'morning' ? 'current' : 'morning';
                  });
                  // Force immediate rebuild to ensure all widgets refresh
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: (_selectedTimePeriod == 'morning' || (isMorning && _selectedTimePeriod == 'current'))
                      ? LinearGradient(
                          colors: [SpaceColors.starYellow.withOpacity(0.8), SpaceColors.starYellow.withOpacity(0.6)],
                        )
                      : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            color: (_selectedTimePeriod == 'morning' || (isMorning && _selectedTimePeriod == 'current'))
                                ? SpaceColors.spaceBlack : SpaceColors.starWhiteSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            localizationService.morning,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: (_selectedTimePeriod == 'morning' || (isMorning && _selectedTimePeriod == 'current'))
                                  ? SpaceColors.spaceBlack : SpaceColors.starWhiteSecondary,
                              fontWeight: (_selectedTimePeriod == 'morning' || (isMorning && _selectedTimePeriod == 'current'))
                                  ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${dataManager.morningStartHour}h-${dataManager.morningEndHour}h',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (_selectedTimePeriod == 'morning' || (isMorning && _selectedTimePeriod == 'current'))
                              ? SpaceColors.spaceBlack.withOpacity(0.8) : SpaceColors.starWhiteTertiary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimePeriod = _selectedTimePeriod == 'evening' ? 'current' : 'evening';
                  });
                  // Force immediate rebuild to ensure all widgets refresh
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: (_selectedTimePeriod == 'evening' || (isEvening && _selectedTimePeriod == 'current'))
                      ? LinearGradient(
                          colors: [SpaceColors.nebulaPink.withOpacity(0.8), SpaceColors.nebulaPinkDark.withOpacity(0.6)],
                        )
                      : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            color: (_selectedTimePeriod == 'evening' || (isEvening && _selectedTimePeriod == 'current'))
                                ? SpaceColors.spaceBlack : SpaceColors.starWhiteSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            localizationService.evening,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: (_selectedTimePeriod == 'evening' || (isEvening && _selectedTimePeriod == 'current'))
                                  ? SpaceColors.spaceBlack : SpaceColors.starWhiteSecondary,
                              fontWeight: (_selectedTimePeriod == 'evening' || (isEvening && _selectedTimePeriod == 'current'))
                                  ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${dataManager.eveningStartHour}h-${dataManager.eveningEndHour}h',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (_selectedTimePeriod == 'evening' || (isEvening && _selectedTimePeriod == 'current'))
                              ? SpaceColors.spaceBlack.withOpacity(0.8) : SpaceColors.starWhiteTertiary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernDigitalClock() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final localizationService = Provider.of<LocalizationService>(context, listen: false);
        final now = DateTime.now();
        final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final secondsString = now.second.toString().padLeft(2, '0');
        final dateString = '${now.day} ${_getMonthName(now.month)}';
        final dayName = localizationService.getDayShortName(now.weekday - 1);
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SpaceColors.cosmicBlue.withOpacity(0.9),
                SpaceColors.spacePurple.withOpacity(0.8),
                SpaceColors.nebulaPink.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SpaceColors.starYellow.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: SpaceColors.cosmicBlue.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: SpaceColors.nebulaPink.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time display with glow effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: SpaceColors.spaceBlack.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SpaceColors.starYellow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Digital time with glowing effect
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          SpaceColors.starWhite,
                          SpaceColors.starYellow,
                          SpaceColors.starWhite,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        timeString,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: SpaceColors.starYellow.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Animated seconds
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SpaceColors.nebulaPink.withOpacity(0.8),
                            SpaceColors.nebulaPinkDark.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        secondsString,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Date and day with elegant styling
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SpaceColors.cosmicBlue.withOpacity(0.6),
                          SpaceColors.spacePurple.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dayName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.starWhiteSecondary,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    return localizationService.getMonthName(month);
  }

  String _getGreetingMessage() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return '${localizationService.goodMorning}, ${localizationService.isFrench ? 'navigateur stellaire' : 'star navigator'}! ☀️';
    } else if (hour >= 12 && hour < 17) {
      return '${localizationService.goodAfternoon}, ${localizationService.isFrench ? 'navigateur stellaire' : 'star navigator'}! ☀️';
    } else {
      return '${localizationService.goodEvening}, ${localizationService.isFrench ? 'navigateur stellaire' : 'star navigator'}! 🌙';
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showTaskAssignmentDialog(BuildContext context, Task task, DataManager dataManager, LocalizationService localizationService) {
    // Show dialog to select which user to assign the task to
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SpaceColors.darkMatter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            task.customImage != null
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.iconColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.memory(
                        task.customImage!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: task.iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      task.icon,
                      color: task.iconColor,
                      size: 20,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizationService.assignTask,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SpaceColors.starWhite,
                    ),
                  ),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SpaceColors.nebulaPink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizationService.isFrench 
                ? 'Sélectionnez un utilisateur :' 
                : 'Select a user:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SpaceColors.starWhiteSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...dataManager.users.map((user) => 
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: SpaceColors.spacePurple,
                  backgroundImage: user.profilePicture != null 
                    ? MemoryImage(user.profilePicture!) 
                    : null,
                  child: user.profilePicture == null 
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: SpaceColors.starWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                title: Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceColors.starWhite,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _assignTaskToUser(task, user, dataManager, localizationService);
                },
              ),
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              localizationService.cancel,
              style: const TextStyle(color: SpaceColors.starWhiteSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _assignTaskToUser(Task task, User user, DataManager dataManager, LocalizationService localizationService) {
    // Show the full assignment dialog from user dashboard
    showDialog(
      context: context,
      builder: (context) => TaskAssignmentDialog(
        task: task,
        user: user,
        onAssign: (updatedTask) {
          dataManager.updateTask(updatedTask);
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizationService.getTaskAssigned(task.title, user.name),
                style: const TextStyle(color: SpaceColors.starWhite),
              ),
              backgroundColor: SpaceColors.galaxyGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Trigger refresh
          setState(() {});
        },
      ),
    );
  }


}