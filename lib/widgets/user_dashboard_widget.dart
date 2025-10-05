import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/widgets/modern_task_card.dart';
import 'package:dreamflow/widgets/add_task_dialog.dart';
import 'package:dreamflow/widgets/day_selector_widget.dart';
import 'package:dreamflow/widgets/time_period_selector_widget.dart';
import 'package:dreamflow/widgets/modern_progress_ring.dart';
import 'package:dreamflow/theme.dart';

class UserDashboardWidget extends StatefulWidget {
final User user;
final DayOfWeek currentDay;
final bool isExpanded;
final String selectedTimePeriod;
final Function(bool) onExpandToggle;

const UserDashboardWidget({
Key? key,
required this.user,
required this.currentDay,
required this.isExpanded,
required this.selectedTimePeriod,
required this.onExpandToggle,
}) : super(key: key);

@override
State<UserDashboardWidget> createState() => _UserDashboardWidgetState();
}

class _UserDashboardWidgetState extends State<UserDashboardWidget>
with TickerProviderStateMixin {
late AnimationController _progressController;
late AnimationController _heroController;
late AnimationController _shineController;
late AnimationController _tasksController;
late Animation<double> _progressAnimation;
late Animation<double> _heroScaleAnimation;
late Animation<double> _shineAnimation;
late Animation<double> _tasksSlideAnimation;

bool _showAvailableTasksDropZone = false;
int _lastCompletedCount = 0;

@override
void initState() {
super.initState();

// Progress animation with bounce effect
_progressController = AnimationController(
duration: const Duration(milliseconds: 1500),
vsync: this,
);

// Hero hover animation
_heroController = AnimationController(
duration: const Duration(milliseconds: 200),
vsync: this,
);

// Shine effect for completed progress
_shineController = AnimationController(
duration: const Duration(milliseconds: 2000),
vsync: this,
);

// Tasks slide-in animation
_tasksController = AnimationController(
duration: const Duration(milliseconds: 800),
vsync: this,
);

_progressAnimation = CurvedAnimation(
parent: _progressController,
curve: Curves.elasticOut,
);

_heroScaleAnimation = Tween<double>(
begin: 1.0,
end: 1.05,
).animate(CurvedAnimation(
parent: _heroController,
curve: Curves.easeInOut,
));

_shineAnimation = Tween<double>(
begin: 0.0,
end: 1.0,
).animate(CurvedAnimation(
parent: _shineController,
curve: Curves.easeInOut,
));

_tasksSlideAnimation = CurvedAnimation(
parent: _tasksController,
curve: Curves.easeOutBack,
);

// Start animations
_progressController.forward();
_tasksController.forward();

// Don't start shine animation here - it will be started when tasks are completed
}

@override
void dispose() {
_progressController.dispose();
_heroController.dispose();
_shineController.dispose();
_tasksController.dispose();
super.dispose();
}

  @override
  void didUpdateWidget(UserDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTimePeriod != widget.selectedTimePeriod) {
      // Force animations when time period changes
      _progressController.forward();
    }
    // Force refresh to ensure progress ring updates immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

@override
Widget build(BuildContext context) {
return Consumer<DataManager>(
builder: (context, dataManager, child) {
// Filter tasks based on selected time period
final todayTasks = dataManager.getTasksForUserByPeriod(
widget.user.id,
widget.currentDay,
widget.selectedTimePeriod
);

final completedToday = todayTasks.where((task) =>
task.isCompletedForDay(widget.currentDay)
).length;

final totalToday = todayTasks.length;
final progressPercentage = totalToday > 0 ? completedToday / totalToday : 0.0;

// Trigger animation when completed count changes
if (completedToday != _lastCompletedCount) {
_lastCompletedCount = completedToday;

// Always trigger a fresh animation for progress changes
if (_progressController.isAnimating) {
_progressController.stop();
}
_progressController.reset();
_progressController.forward();

// Start/stop shine animation based on completion
if (progressPercentage >= 1.0 && !_shineController.isAnimating) {
_shineController.repeat(reverse: true);
} else if (progressPercentage < 1.0 && _shineController.isAnimating) {
_shineController.stop();
_shineController.reset();
}
}

return MouseRegion(
onEnter: (_) => _heroController.forward(),
onExit: (_) => _heroController.reverse(),
child: AnimatedBuilder(
animation: _heroScaleAnimation,
builder: (context, child) {
return Transform.scale(
scale: _heroScaleAnimation.value,
child: Container(
margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
gradient: SpaceColors.cardGradient,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: SpaceColors.spacePurple.withOpacity(0.3),
blurRadius: 20,
offset: const Offset(0, 8),
),
BoxShadow(
color: SpaceColors.nebulaPink.withOpacity(0.1),
blurRadius: 40,
offset: const Offset(0, 12),
),
],
border: Border.all(
color: SpaceColors.spacePurple.withOpacity(0.4),
width: 1.5,
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
// Profile section with animated progress
_buildProfileSection(progressPercentage, completedToday, totalToday),

const SizedBox(width: 16),

// Tasks section - directly visible
Expanded(
child: DragTarget<Task>(
onAccept: (task) {
_assignTaskToUser(task, dataManager);
},
builder: (context, candidateData, rejectedData) {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
border: candidateData.isNotEmpty
? Border.all(
color: SpaceColors.galaxyGreen,
width: 2,
)
: null,
color: candidateData.isNotEmpty
? SpaceColors.galaxyGreen.withOpacity(0.1)
: null,
),
child: _buildTasksSection(context, todayTasks, dataManager),
);
},
),
),

// Add tasks button
_buildAddTasksButton(context, dataManager),
],
),
),
);
},
),
);
},
);
}

Widget _buildProfileSection(double progressPercentage, int completedToday, int totalToday) {
return Consumer<DataManager>(
builder: (context, dataManager, child) {
return Column(
children: [
        // Modern progress ring with profile picture
        ModernProgressRing(
          key: ValueKey('${widget.user.id}_${completedToday}_${totalToday}_${widget.currentDay}_${widget.selectedTimePeriod}_${DateTime.now().millisecondsSinceEpoch}'),
          totalTasks: totalToday,
          completedTasks: completedToday,
          size: 100,
          style: _getProgressStyle(completedToday, totalToday, dataManager),
child: Container(
width: 70,
height: 70,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: SpaceColors.starWhite.withOpacity(0.4),
width: 3,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.4),
blurRadius: 16,
offset: const Offset(0, 6),
),
BoxShadow(
color: SpaceColors.spacePurple.withOpacity(0.3),
blurRadius: 20,
spreadRadius: 2,
),
],
),
child: ClipOval(
child: widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty
? Image.memory(
widget.user.profilePicture!,
fit: BoxFit.cover,
width: 70,
height: 70,
errorBuilder: (context, error, stackTrace) {
print('Error loading profile picture: $error');
return Container(
width: 70,
height: 70,
decoration: const BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
SpaceColors.spacePurple,
SpaceColors.cosmicBlue,
SpaceColors.nebulaPink,
],
),
),
child: const Icon(
Icons.person,
size: 35,
color: SpaceColors.starWhite,
),
);
},
)
: Container(
width: 70,
height: 70,
decoration: const BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
SpaceColors.spacePurple,
SpaceColors.cosmicBlue,
SpaceColors.nebulaPink,
],
),
),
child: const Icon(
Icons.person,
size: 35,
color: SpaceColors.starWhite,
),
),
),),
),

const SizedBox(height: 6),

// User name with larger font for readability
Text(
widget.user.name,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.bold,
color: SpaceColors.starWhite,
fontSize: 16,
),
textAlign: TextAlign.center,
),

const SizedBox(height: 2),

// Progress text with emojis
Text(
'$completedToday/$totalToday ${_getProgressEmoji(progressPercentage)}',
style: Theme.of(context).textTheme.bodyMedium?.copyWith(
color: progressPercentage >= 1.0
? SpaceColors.galaxyGreen
: SpaceColors.starWhiteSecondary,
fontWeight: FontWeight.w600,
fontSize: 14,
),
),
],
);
},
);
}

Widget _buildTasksSection(BuildContext context, List<Task> todayTasks, DataManager dataManager) {
if (todayTasks.isEmpty) {
return AnimatedBuilder(
animation: _tasksSlideAnimation,
builder: (context, child) {
return Transform.translate(
offset: Offset(50 * (1 - _tasksSlideAnimation.value), 0),
child: DragTarget<Task>(
onAccept: (task) {
_assignTaskToUser(task, dataManager);
},
builder: (context, candidateData, rejectedData) {
final isHovering = candidateData.isNotEmpty;
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: isHovering
? SpaceColors.nebulaPink.withOpacity(0.2)
: SpaceColors.darkMatter.withOpacity(0.5),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: isHovering
? SpaceColors.nebulaPink.withOpacity(0.6)
: SpaceColors.spacePurple.withOpacity(0.3),
width: isHovering ? 2 : 1,
),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
isHovering ? Icons.add_task : Icons.celebration,
size: 48,
color: isHovering ? SpaceColors.nebulaPink : SpaceColors.starYellow,
),
const SizedBox(height: 12),
Consumer<LocalizationService>(
builder: (context, localizationService, child) {
return Text(
isHovering
? localizationService.dropTaskHere
: localizationService.noTasksToday,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.w600,
),
textAlign: TextAlign.center,
);
},
),
],
),
);
},
),
);
},
);
}

return AnimatedBuilder(
animation: _tasksSlideAnimation,
builder: (context, child) {
return Transform.translate(
offset: Offset(50 * (1 - _tasksSlideAnimation.value), 0),
child: DragTarget<Task>(
onAccept: (task) {
_assignTaskToUser(task, dataManager);
},
builder: (context, candidateData, rejectedData) {
final isHovering = candidateData.isNotEmpty;
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
border: isHovering
? Border.all(
color: SpaceColors.nebulaPink.withOpacity(0.6),
width: 2,
)
: null,
),
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: todayTasks.asMap().entries.map((entry) {
final index = entry.key;
final task = entry.value;

return AnimatedBuilder(
animation: _tasksController,
builder: (context, child) {
final delay = index * 0.1;
final animationValue = (_tasksController.value - delay).clamp(0.0, 1.0);

return Padding(
padding: EdgeInsets.only(
right: index < todayTasks.length - 1 ? 12 : 0,
),
child: Transform.translate(
offset: Offset(30 * (1 - animationValue), 0),
child: Transform.scale(
scale: 0.8 + (0.2 * animationValue),
                    child: SizedBox(
                      width: 120,
                      child: EnhancedTaskCard(
                        key: ValueKey('${task.id}_${task.isCompletedForDay(widget.currentDay)}_${widget.currentDay}'),
                        task: task,
                        currentDay: widget.currentDay,
                        onTap: () {
                          dataManager.completeTask(task.id, widget.currentDay);
                          // Force immediate refresh of progress ring
                          setState(() {});
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() {});
                          });
                        },
                      ),
                    ),
),
),
);
},
);
}).toList(),
),
),
);
},
),
);
},
);
}

String _getProgressEmoji(double progress) {
if (progress >= 1.0) return '🎉';
if (progress >= 0.75) return '🌟';
if (progress >= 0.5) return '🚀';
return '⭐';
}

ProgressRingStyle _getProgressStyle(int completed, int total, DataManager dataManager) {
if (total == 0) return ProgressRingStyle.neonGlow;

final styleSettings = dataManager.progressRingStyle;

// Use fixed style
switch (styleSettings) {
case 'neon':
return ProgressRingStyle.neonGlow;
case 'rainbow':
return ProgressRingStyle.cosmicRainbow;
case 'crystal':
return ProgressRingStyle.crystalPrism;
default:
return ProgressRingStyle.neonGlow;
}
}

Widget _buildAddTasksButton(BuildContext context, DataManager dataManager) {
return Consumer<LocalizationService>(
builder: (context, localizationService, child) {
return Column(
children: [
// Vertical layout for smaller buttons
Column(
children: [
// Assign existing tasks button
Material(
color: Colors.transparent,
child: InkWell(
onTap: () {
print('Assigner des tâches button tapped!');
print('Current _showAvailableTasksDropZone: $_showAvailableTasksDropZone');

// Get available tasks for debugging
final availableTasks = dataManager.tasks.where((task) =>
task.assignedTo == null && task.isAssignedToDay(widget.currentDay)
).toList();

print('Available tasks count: ${availableTasks.length}');
print('Total tasks in system: ${dataManager.tasks.length}');

setState(() {
_showAvailableTasksDropZone = !_showAvailableTasksDropZone;
});

print('New _showAvailableTasksDropZone: $_showAvailableTasksDropZone');
},
borderRadius: BorderRadius.circular(16),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
_showAvailableTasksDropZone ? SpaceColors.galaxyGreen : SpaceColors.nebulaPink,
_showAvailableTasksDropZone ? SpaceColors.galaxyGreen.withOpacity(0.8) : SpaceColors.nebulaPinkDark
],
),
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: (_showAvailableTasksDropZone ? SpaceColors.galaxyGreen : SpaceColors.nebulaPink).withOpacity(0.3),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
_showAvailableTasksDropZone ? Icons.close : Icons.task_alt,
color: SpaceColors.starWhite,
size: 16,
),
const SizedBox(width: 6),
Text(
_showAvailableTasksDropZone ? localizationService.close : localizationService.assignTasks,
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.w600,
),
),
],
),
),
),
),
const SizedBox(height: 6),
// Create new task button
Material(
color: Colors.transparent,
child: InkWell(
onTap: () => _showAddTaskDialog(context),
borderRadius: BorderRadius.circular(16),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [SpaceColors.cosmicBlue, SpaceColors.cosmicBlueDark],
),
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: SpaceColors.cosmicBlue.withOpacity(0.3),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.add,
color: SpaceColors.starWhite,
size: 16,
),
const SizedBox(width: 6),
Text(
localizationService.newTask,
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.w600,
),
),
],
),
),
),
),
],
),
// Show available tasks when requested
AnimatedContainer(
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
height: _showAvailableTasksDropZone ? null : 0,
child: _showAvailableTasksDropZone
? Column(
children: [
const SizedBox(height: 12),
_buildAvailableTasksDropZone(context, dataManager),
],
)
: const SizedBox.shrink(),
),
],
);
},
);
}

Widget _buildAvailableTasksDropZone(BuildContext context, DataManager dataManager) {
return Consumer2<LocalizationService, DataManager>(
builder: (context, localizationService, dataManager, child) {
// Get ALL unassigned tasks using the dedicated method
final allUnassignedTasks = dataManager.getAllUnassignedTasks();

// Debug: Print available tasks count
print('=== DEBUG: Available Tasks Analysis ===');
print('Available tasks for ${widget.user.name}: ${allUnassignedTasks.length}');
print('Total tasks in system: ${dataManager.tasks.length}');
print('Current day: ${widget.currentDay.name}');

// Print detailed info for each task in the system
print('\n--- All Tasks in System ---');
for (final task in dataManager.tasks) {
print('Task: ${task.title}');
print('  - ID: ${task.id}');
print('  - AssignedTo: ${task.assignedTo ?? "null"}');
print('  - AssignedDays: ${task.assignedDays.map((d) => d.name).join(', ')}');
print('  - IsAssignedToCurrentDay: ${task.isAssignedToDay(widget.currentDay)}');
print('');
}

// Print each available task for debugging  
print('\n--- Available Unassigned Tasks ---');
for (final task in allUnassignedTasks) {
print('Available task: ${task.title}');
print('  - Days: ${task.assignedDays.map((d) => d.name).join(', ')}');
print('  - IsAssignedToCurrentDay: ${task.isAssignedToDay(widget.currentDay)}');
}

return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
SpaceColors.darkMatter.withOpacity(0.8),
SpaceColors.darkMatterLight.withOpacity(0.6),
],
),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: SpaceColors.nebulaPink.withOpacity(0.3),
width: 2,
),
boxShadow: [
BoxShadow(
color: SpaceColors.nebulaPink.withOpacity(0.2),
blurRadius: 12,
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
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: SpaceColors.nebulaPink.withOpacity(0.2),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
Icons.task_alt,
color: SpaceColors.nebulaPink,
size: 20,
),
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
localizationService.getTaskAssignInstruction(widget.user.name),
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.starWhiteSecondary,
),
),
],
),
),
Icon(
Icons.touch_app,
color: SpaceColors.starYellow,
size: 18,
),
],
),
const SizedBox(height: 16),

// Available tasks
if (allUnassignedTasks.isEmpty)
Column(
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: SpaceColors.spaceBlack.withOpacity(0.3),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: SpaceColors.starWhiteSecondary.withOpacity(0.2),
),
),
child: Column(
children: [
Icon(
Icons.info_outline,
color: SpaceColors.starWhiteSecondary,
size: 32,
),
const SizedBox(height: 8),
Text(
localizationService.noTasksAvailable,
style: Theme.of(context).textTheme.titleSmall?.copyWith(
color: SpaceColors.starWhiteSecondary,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
localizationService.isFrench
? 'Créez des tâches dans les paramètres pour les assigner'
: 'Create tasks in settings to assign them',
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.starWhiteTertiary,
),
textAlign: TextAlign.center,
),
],
),
),
const SizedBox(height: 12),
// Show debug info when no tasks are available
Container(
width: double.infinity,
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: SpaceColors.cosmicBlue.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: SpaceColors.cosmicBlue.withOpacity(0.3),
),
),
child: Text(
'DEBUG: ${dataManager.tasks.length} tâches totales dans le système\n'
'${allUnassignedTasks.length} tâches non assignées trouvées\n'
'Jour actuel: ${widget.currentDay.name}',
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.cosmicBlue,
fontSize: 10,
),
),
),
],
)
else
// Display tasks in multiple rows using Wrap
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Show count info
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: SpaceColors.galaxyGreen.withOpacity(0.2),
borderRadius: BorderRadius.circular(8),
),
child: Text(
'${allUnassignedTasks.length} tâche(s) disponible(s)',
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.galaxyGreen,
fontWeight: FontWeight.w600,
),
),
),
const SizedBox(height: 12),
Wrap(
spacing: 8.0,
runSpacing: 8.0,
children: allUnassignedTasks.map((task) {
return GestureDetector(
onTap: () {
print('Task tapped: ${task.title}');
_showTaskAssignmentDialog(context, task, dataManager, localizationService);
},
child: _buildTaskChip(task),
);
}).toList(),
),
],
),
],
),
);
},
);
}

Widget _buildTaskChip(Task task) {
return Container(
width: 80, // Slightly smaller width for better fit in multiple rows
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
task.iconColor.withOpacity(0.3),
task.iconColor.withOpacity(0.15),
],
),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: task.iconColor.withOpacity(0.6),
width: 1.5,
),
boxShadow: [
BoxShadow(
color: task.iconColor.withOpacity(0.2),
blurRadius: 4,
offset: const Offset(0, 2),
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
// Task icon or custom image
task.customImage != null
? ClipRRect(
borderRadius: BorderRadius.circular(8),
child: Container(
width: 30,
height: 30,
child: Stack(
fit: StackFit.expand,
children: [
Image.memory(
task.customImage!,
fit: BoxFit.cover,
),
// Subtle overlay for consistency
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.transparent,
task.iconColor.withOpacity(0.1),
],
),
),
),
],
),
),
)
: Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: task.iconColor.withOpacity(0.2),
borderRadius: BorderRadius.circular(8),
),
child: Icon(
task.icon,
color: task.iconColor,
size: 18,
),
),
const SizedBox(height: 4),
// Task title
Text(
task.title,
style: TextStyle(
color: SpaceColors.starWhite,
fontSize: 11,
fontWeight: FontWeight.w600,
),
textAlign: TextAlign.center,
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
// Category indicator
if (task.category != 'General') ...[
const SizedBox(height: 2),
Container(
padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
decoration: BoxDecoration(
color: task.iconColor.withOpacity(0.3),
borderRadius: BorderRadius.circular(6),
),
child: Text(
task.category,
style: TextStyle(
color: SpaceColors.starWhite,
fontSize: 8,
fontWeight: FontWeight.w500,
),
),
),
],
],
),
);
}

void _assignTaskToUser(Task task, DataManager dataManager) {
  // Ensure task with custom image is preserved
  final updatedTask = task.copyWith(
    assignedTo: widget.user.id,
    assignedDays: task.assignedDays.isEmpty ? [widget.currentDay] : task.assignedDays,
    completionStatus: task.assignedDays.isEmpty 
      ? {widget.currentDay: false}
      : {for (DayOfWeek day in task.assignedDays) day: false},
  );
  
  dataManager.updateTask(updatedTask);
  
  // Show success message
  final localizationService = Provider.of<LocalizationService>(context, listen: false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(localizationService.getTaskAssigned(task.title, widget.user.name)),
      backgroundColor: SpaceColors.galaxyGreen,
      duration: const Duration(seconds: 2),
    ),
  );
}

void _showTaskAssignmentDialog(BuildContext context, Task task, DataManager dataManager, LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (context) => TaskAssignmentDialog(
        user: widget.user,
        task: task,
        onAssign: (updatedTask) {
          dataManager.updateTask(updatedTask);
          // Force UI update immediately
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    ).then((_) {
      // Force multiple refreshes to ensure new task appears immediately
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
            // Triple refresh pour garantir l'affichage immédiat
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) setState(() {});
            });
          }
        });
      }
    });
  }
}

// Modern progress ring styles are now handled by ModernProgressRing widget

// Enhanced task card with better animations and visual emphasis
class EnhancedTaskCard extends StatefulWidget {
final Task task;
final DayOfWeek currentDay;
final VoidCallback onTap;

const EnhancedTaskCard({
Key? key,
required this.task,
required this.currentDay,
required this.onTap,
}) : super(key: key);

@override
State<EnhancedTaskCard> createState() => _EnhancedTaskCardState();
}

class _EnhancedTaskCardState extends State<EnhancedTaskCard>
with TickerProviderStateMixin {
late AnimationController _hoverController;
late AnimationController _completionController;
late AnimationController _pulseController;
late Animation<double> _scaleAnimation;
late Animation<double> _completionAnimation;
late Animation<double> _pulseAnimation;
bool _isHovered = false;

@override
void initState() {
super.initState();

_hoverController = AnimationController(
duration: const Duration(milliseconds: 200),
vsync: this,
);

_completionController = AnimationController(
duration: const Duration(milliseconds: 800),
vsync: this,
);

_pulseController = AnimationController(
duration: const Duration(milliseconds: 1500),
vsync: this,
);

_scaleAnimation = Tween<double>(
begin: 1.0,
end: 1.1,
).animate(CurvedAnimation(
parent: _hoverController,
curve: Curves.easeInOut,
));

_completionAnimation = CurvedAnimation(
parent: _completionController,
curve: Curves.elasticOut,
);

_pulseAnimation = Tween<double>(
begin: 1.0,
end: 1.2,
).animate(CurvedAnimation(
parent: _pulseController,
curve: Curves.easeInOut,
));

// Set initial state based on completion status
WidgetsBinding.instance.addPostFrameCallback((_) {
if (mounted) {
if (widget.task.isCompletedForDay(widget.currentDay)) {
_completionController.value = 1.0;
_pulseController.repeat(reverse: true);
} else {
_completionController.value = 0.0;
_pulseController.value = 0.0;
}
}
});
}

@override
void dispose() {
_hoverController.dispose();
_completionController.dispose();
_pulseController.dispose();
super.dispose();
}

  void _handleTap() {
    _hoverController.forward().then((_) {
      _hoverController.reverse();
    });

    // Get current task state from context
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final currentTask = dataManager.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    // Store the state before toggling
    final wasCompleted = currentTask.isCompletedForDay(widget.currentDay);

    widget.onTap(); // This toggles the task completion

    // Force immediate state update
    setState(() {});
    
    // Wait a frame for the DataManager state to update, then animate based on new state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final updatedTask = dataManager.tasks.firstWhere(
          (t) => t.id == widget.task.id,
          orElse: () => widget.task,
        );
        final isNowCompleted = updatedTask.isCompletedForDay(widget.currentDay);

        if (!wasCompleted && isNowCompleted) {
          // Task was just completed - start animations
          _completionController.forward();
          _pulseController.repeat(reverse: true);
        } else if (wasCompleted && !isNowCompleted) {
          // Task was just uncompleted - reset animations immediately
          _completionController.stop();
          _completionController.value = 0.0; // Force value to 0
          _pulseController.stop();
          _pulseController.value = 0.0; // Force value to 0
        }
        
        // Force another rebuild to ensure everything is updated
        setState(() {});
      }
    });
  }

@override
Widget build(BuildContext context) {
return Consumer<DataManager>(
builder: (context, dataManager, child) {
// Get the updated task from DataManager
final currentTask = dataManager.tasks.firstWhere(
(t) => t.id == widget.task.id,
orElse: () => widget.task,
);
final isCompleted = currentTask.isCompletedForDay(widget.currentDay);

return GestureDetector(
onTap: _handleTap,
child: MouseRegion(
onEnter: (_) {
setState(() => _isHovered = true);
_hoverController.forward();
},
onExit: (_) {
setState(() => _isHovered = false);
_hoverController.reverse();
},
child: AnimatedBuilder(
animation: Listenable.merge([_scaleAnimation, _completionAnimation, _pulseAnimation]),
builder: (context, child) {
return Transform.scale(
scale: _scaleAnimation.value * (isCompleted ? _pulseAnimation.value : 1.0),
child: Container(
width: 120,
height: 120,
decoration: BoxDecoration(
gradient: isCompleted
? LinearGradient(
colors: [
SpaceColors.galaxyGreen,
SpaceColors.starYellow,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
)
: LinearGradient(
colors: [
SpaceColors.darkMatter,
SpaceColors.darkMatterLight,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: isCompleted
? SpaceColors.galaxyGreen.withOpacity(0.8)
: SpaceColors.spacePurple.withOpacity(0.4),
width: 2,
),
boxShadow: [
BoxShadow(
color: isCompleted
? SpaceColors.galaxyGreen.withOpacity(0.4)
: SpaceColors.spacePurple.withOpacity(0.2),
blurRadius: _isHovered ? 20 : 8,
offset: const Offset(0, 6),
spreadRadius: isCompleted ? 2 : 0,
),
],
),
child: Stack(
alignment: Alignment.center,
children: [
// Main task icon or custom image - filling the card for maximum visual impact
widget.task.customImage != null
? Positioned.fill(
child: ClipRRect(
borderRadius: BorderRadius.circular(18),
child: Stack(
fit: StackFit.expand,
children: [
Image.memory(
widget.task.customImage!,
fit: BoxFit.cover,
),
// Strong overlay for better text readability and completion effect
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: _completionAnimation.value > 0.0
? [
SpaceColors.galaxyGreen.withOpacity(0.4 * _completionAnimation.value),
SpaceColors.galaxyGreen.withOpacity(0.6 * _completionAnimation.value),
SpaceColors.galaxyGreen.withOpacity(0.8 * _completionAnimation.value),
]
: [
Colors.transparent,
Colors.black.withOpacity(0.4),
Colors.black.withOpacity(0.7),
],
stops: const [0.0, 0.6, 1.0],
),
),
),
],
),
),
)
: Icon(
widget.task.icon,
size: 48,
color: isCompleted ? Colors.white : widget.task.iconColor,
),

// Completion checkmark with bounce
if (isCompleted)
Positioned(
top: 8,
right: 8,
child: Transform.scale(
scale: _completionAnimation.value,
child: Container(
width: 24,
height: 24,
decoration: const BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
),
child: const Icon(
Icons.check,
color: SpaceColors.galaxyGreen,
size: 16,
),
),
),
),

// Sparkle effect for completed tasks
if (isCompleted)
...List.generate(3, (index) {
return Positioned(
top: 10 + (index * 5),
left: 10 + (index * 8),
child: AnimatedBuilder(
animation: _pulseAnimation,
builder: (context, child) {
return Transform.scale(
scale: 0.5 + (_pulseAnimation.value * 0.5),
child: Icon(
Icons.auto_awesome,
size: 12,
color: Colors.white.withOpacity(0.8),
),
);
},
),
);
}),

// Task title at bottom - smaller for icon emphasis
Positioned(
bottom: 6,
left: 4,
right: 4,
child: Consumer<LocalizationService>(
builder: (context, localizationService, child) {
return Text(
localizationService.getTaskTitle(widget.task.title),
style: Theme.of(context).textTheme.labelSmall?.copyWith(
color: isCompleted ? Colors.white : SpaceColors.starWhiteSecondary,
fontWeight: FontWeight.w600,
fontSize: 10,
),
textAlign: TextAlign.center,
maxLines: 1,
overflow: TextOverflow.ellipsis,
);
},
),
),
],
),
),
);
},
),
),
);
},
);
}
}

// Task Assignment Dialog with day and time period selection
class TaskAssignmentDialog extends StatefulWidget {
final Task task;
final User user;
final Function(Task) onAssign;

const TaskAssignmentDialog({
Key? key,
required this.task,
required this.user,
required this.onAssign,
}) : super(key: key);

@override
State<TaskAssignmentDialog> createState() => _TaskAssignmentDialogState();
}

class _TaskAssignmentDialogState extends State<TaskAssignmentDialog>
with TickerProviderStateMixin {
List<DayOfWeek> _selectedDays = [];
TimePeriod _selectedTimePeriod = TimePeriod.both;

late AnimationController _slideController;
late Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

// Initialize with only today's day for new assignments
_selectedDays = [Task.today];
_selectedTimePeriod = widget.task.timePeriod;

_slideController = AnimationController(
duration: const Duration(milliseconds: 300),
vsync: this,
);
_slideAnimation = Tween<Offset>(
begin: const Offset(0.0, 0.3),
end: Offset.zero,
).animate(CurvedAnimation(
parent: _slideController,
curve: Curves.easeOutBack,
));

_slideController.forward();
}

@override
void dispose() {
_slideController.dispose();
super.dispose();
}

void _assignTask() {
  final localizationService = Provider.of<LocalizationService>(context, listen: false);
  
  if (_selectedDays.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationService.selectAtLeastOneDay),
        backgroundColor: SpaceColors.nebulaPinkDark,
      ),
    );
    return;
  }
  
  final updatedTask = widget.task.copyWith(
    assignedTo: widget.user.id,
    assignedDays: _selectedDays,
    timePeriod: _selectedTimePeriod,
    completionStatus: {for (DayOfWeek day in _selectedDays) day: false},
    customImage: widget.task.customImage, // Preserve custom image explicitly
  );
  
  // Close dialog first
  Navigator.of(context).pop();
  
  // Then assign task and notify
  widget.onAssign(updatedTask);
  
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(localizationService.getTaskAssigned(updatedTask.title, widget.user.name)),
      backgroundColor: SpaceColors.galaxyGreen,
      duration: const Duration(seconds: 2),
    ),
  );
}

@override
Widget build(BuildContext context) {
return Consumer<LocalizationService>(
builder: (context, localizationService, child) {
final taskTitle = localizationService.getTaskTitle(widget.task.title);
final taskDescription = localizationService.getTaskDescription(widget.task.description);

return Dialog(
backgroundColor: Colors.transparent,
child: SlideTransition(
position: _slideAnimation,
child: Container(
constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [SpaceColors.darkMatter, SpaceColors.spaceBlackLight],
),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: SpaceColors.nebulaPink.withOpacity(0.3),
width: 1,
),
boxShadow: [
BoxShadow(
color: SpaceColors.spaceBlack.withOpacity(0.8),
blurRadius: 20,
offset: const Offset(0, 10),
),
],
),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
// Header
Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: widget.task.iconColor.withOpacity(0.2),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
widget.task.icon,
color: widget.task.iconColor,
size: 28,
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
localizationService.assignTask,
style: Theme.of(context).textTheme.titleLarge?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
taskTitle,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
color: SpaceColors.nebulaPink,
fontWeight: FontWeight.w600,
),
),
],
),
),
],
),
const SizedBox(height: 20),

// User info
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
SpaceColors.starYellow.withOpacity(0.15),
SpaceColors.starYellow.withOpacity(0.05),
],
),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: SpaceColors.starYellow.withOpacity(0.3),
width: 1,
),
),
child: Row(
children: [
CircleAvatar(
radius: 20,
backgroundColor: SpaceColors.starYellow.withOpacity(0.2),
backgroundImage: widget.user.profilePicture != null
? MemoryImage(widget.user.profilePicture!)
: null,
child: widget.user.profilePicture == null
? Text(
widget.user.name.substring(0, 1).toUpperCase(),
style: const TextStyle(
color: SpaceColors.starYellow,
fontWeight: FontWeight.bold,
),
)
: null,
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
localizationService.isFrench
? 'Assigner à:'
: 'Assign to:',
style: Theme.of(context).textTheme.bodySmall?.copyWith(
color: SpaceColors.starWhiteTertiary,
),
),
Text(
widget.user.name,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
color: SpaceColors.starYellow,
fontWeight: FontWeight.bold,
),
),
],
),
),
],
),
),
const SizedBox(height: 20),

// Task description (if available)
if (widget.task.description.isNotEmpty) ...[
Container(
width: double.infinity,
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: SpaceColors.spaceBlack.withOpacity(0.3),
borderRadius: BorderRadius.circular(12),
),
child: Text(
taskDescription,
style: Theme.of(context).textTheme.bodyMedium?.copyWith(
color: SpaceColors.starWhiteSecondary,
),
),
),
const SizedBox(height: 20),
],

// Day selection
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.calendar_today,
color: SpaceColors.nebulaPink,
size: 18,
),
const SizedBox(width: 8),
Text(
localizationService.selectDays,
style: Theme.of(context).textTheme.titleSmall?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.w600,
),
),
],
),
const SizedBox(height: 12),
DaySelectorWidget(
selectedDays: _selectedDays,
onSelectionChanged: (days) {
setState(() {
_selectedDays = days;
});
},
allowMultipleSelection: true,
isCompact: true,
),
],
),
const SizedBox(height: 20),

// Time period selection
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.schedule,
color: SpaceColors.cosmicBlue,
size: 18,
),
const SizedBox(width: 8),
Text(
localizationService.selectTimePeriod,
style: Theme.of(context).textTheme.titleSmall?.copyWith(
color: SpaceColors.starWhite,
fontWeight: FontWeight.w600,
),
),
],
),
const SizedBox(height: 12),
TimePeriodSelectorWidget(
selectedPeriod: _selectedTimePeriod,
onSelectionChanged: (period) {
setState(() {
_selectedTimePeriod = period;
});
},
isCompact: true,
),
],
),
const SizedBox(height: 24),

// Actions
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () => Navigator.of(context).pop(),
style: OutlinedButton.styleFrom(
foregroundColor: SpaceColors.starWhiteSecondary,
side: BorderSide(
color: SpaceColors.starWhiteSecondary.withOpacity(0.5),
width: 1,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: const EdgeInsets.symmetric(vertical: 12),
),
child: Text(
localizationService.cancel,
style: const TextStyle(fontWeight: FontWeight.w500),
),
),
),
const SizedBox(width: 12),
Expanded(
child: ElevatedButton(
onPressed: _assignTask,
style: ElevatedButton.styleFrom(
backgroundColor: SpaceColors.nebulaPink,
foregroundColor: SpaceColors.starWhite,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: const EdgeInsets.symmetric(vertical: 12),
elevation: 8,
shadowColor: SpaceColors.nebulaPink.withOpacity(0.4),
),
child: Text(
localizationService.assign,
style: const TextStyle(fontWeight: FontWeight.bold),
),
),
),
],
),
],
),
),
),
),
);
}
);
}
}