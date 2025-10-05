import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/widgets/day_selector_widget.dart';
import 'package:dreamflow/widgets/time_period_selector_widget.dart';
import 'package:dreamflow/theme.dart';

class UserTaskManagementScreen extends StatefulWidget {
  final User user;

  const UserTaskManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserTaskManagementScreen> createState() => _UserTaskManagementScreenState();
}

class _UserTaskManagementScreenState extends State<UserTaskManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
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
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        final userTasks = dataManager.tasks.where((task) => task.assignedTo == widget.user.id).toList();
        final availableTasks = dataManager.tasks.where((task) => task.assignedTo == null).toList();
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: SpaceColors.spaceGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUserHeader(),
                            const SizedBox(height: 24),
                            _buildAssignedTasks(userTasks, dataManager),
                            const SizedBox(height: 24),
                            _buildAvailableTasks(availableTasks, dataManager),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SpaceColors.darkMatter.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpaceColors.spacePurple.withOpacity(0.4),
                ),
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
              'Task Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SpaceColors.nebulaGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SpaceColors.nebulaPink.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  SpaceColors.starWhite.withOpacity(0.2),
                  SpaceColors.starWhite.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: SpaceColors.starWhite.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: widget.user.profilePicture != null
                ? ClipOval(
                    child: Image.memory(
                      widget.user.profilePicture!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: SpaceColors.starWhite,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crew Member #${widget.user.id.substring(0, 6)}',
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

  Widget _buildAssignedTasks(List<Task> userTasks, DataManager dataManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SpaceColors.galaxyGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.assignment_turned_in,
                color: SpaceColors.galaxyGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Assigned Tasks (${userTasks.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (userTasks.isEmpty)
          _buildEmptyState(
            'No assigned tasks',
            'This crew member has no assigned missions yet',
            Icons.assignment_late,
          )
        else
          SizedBox(
            height: 140, // Hauteur un peu plus grande pour format carré
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: userTasks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final task = userTasks[index];
                return SizedBox(
                  width: 160, // Format plus carré au lieu de 300
                  child: _buildTaskCard(
                    task,
                    dataManager,
                    isAssigned: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAvailableTasks(List<Task> availableTasks, DataManager dataManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SpaceColors.cosmicBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.assignment,
                color: SpaceColors.cosmicBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Available Tasks (${availableTasks.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SpaceColors.starWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (availableTasks.isEmpty)
          _buildEmptyState(
            'No available tasks',
            'All tasks are currently assigned to crew members',
            Icons.assignment_turned_in,
          )
        else
          SizedBox(
            height: 140, // Hauteur un peu plus grande pour format carré
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableTasks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final task = availableTasks[index];
                return SizedBox(
                  width: 160, // Format plus carré au lieu de 300
                  child: _buildTaskCard(
                    task,
                    dataManager,
                    isAssigned: false,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTaskCard(Task task, DataManager dataManager, {required bool isAssigned}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: SpaceColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: SpaceColors.spacePurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône centrée en haut
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: task.iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                task.icon,
                color: task.iconColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            
            // Titre centré
            Consumer<LocalizationService>(
              builder: (context, localizationService, child) {
                return Text(
                  localizationService.getTaskTitle(task.title),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SpaceColors.starWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            
            const Spacer(),
            
            // Bouton d'action en bas
            if (isAssigned)
              _buildActionButton(
                icon: Icons.remove_circle_outline,
                color: SpaceColors.nebulaPink,
                onPressed: () => _unassignTask(task, dataManager),
              )
            else
              _buildActionButton(
                icon: Icons.add_circle_outline,
                color: SpaceColors.galaxyGreen,
                onPressed: () => _showAssignTaskDialog(task, dataManager),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpaceColors.darkMatter.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpaceColors.spacePurple.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              color: SpaceColors.starWhiteSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SpaceColors.starWhiteSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SpaceColors.starWhiteTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _unassignTask(Task task, DataManager dataManager) {
    final updatedTask = task.copyWith(assignedTo: null);
    dataManager.updateTask(updatedTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ ${task.title} unassigned from ${widget.user.name}'),
        backgroundColor: SpaceColors.nebulaPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAssignTaskDialog(Task task, DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) => AssignTaskDialog(
        task: task,
        user: widget.user,
        onAssign: (updatedTask) {
          dataManager.updateTask(updatedTask);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎯 ${task.title} assigned to ${widget.user.name}'),
              backgroundColor: SpaceColors.galaxyGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AssignTaskDialog extends StatefulWidget {
  final Task task;
  final User user;
  final Function(Task) onAssign;

  const AssignTaskDialog({
    Key? key,
    required this.task,
    required this.user,
    required this.onAssign,
  }) : super(key: key);

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  List<DayOfWeek> _selectedDays = [];
  TimePeriod _selectedTimePeriod = TimePeriod.both;

  @override
  void initState() {
    super.initState();
    // Initialize with only today's day for new assignments
    _selectedDays = [Task.today];
    _selectedTimePeriod = widget.task.timePeriod;
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Dialog(
      backgroundColor: SpaceColors.darkMatter,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - Compact
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.task.iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      widget.task.icon,
                      color: widget.task.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizationService.assignTask,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SpaceColors.starWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          localizationService.getTaskTitle(widget.task.title),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SpaceColors.starWhiteSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Days Selection - Compact
              Text(
                '${localizationService.selectDays} ${widget.user.name}:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SpaceColors.starWhite,
                ),
              ),
              const SizedBox(height: 12),
              DaySelectorWidget(
                selectedDays: _selectedDays,
                onSelectionChanged: (days) {
                  setState(() {
                    _selectedDays = days;
                  });
                },
                isCompact: true,
              ),
              const SizedBox(height: 16),
              
              // Time Period Selection - Compact
              TimePeriodSelectorWidget(
                selectedPeriod: _selectedTimePeriod,
                onSelectionChanged: (period) {
                  setState(() {
                    _selectedTimePeriod = period;
                  });
                },
                isCompact: true,
              ),
              const SizedBox(height: 20),
              
              // Action Buttons - Compact
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      localizationService.cancel,
                      style: TextStyle(color: SpaceColors.starWhiteSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedDays.isEmpty
                        ? null
                        : () {
                            final updatedTask = widget.task.copyWith(
                              assignedTo: widget.user.id,
                              assignedDays: _selectedDays,
                              timePeriod: _selectedTimePeriod,
                            );
                            widget.onAssign(updatedTask);
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpaceColors.galaxyGreen,
                      foregroundColor: SpaceColors.spaceBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      localizationService.assign,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}