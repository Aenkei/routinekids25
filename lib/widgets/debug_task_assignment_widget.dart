import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/theme.dart';

/// Widget de débogage pour tester l'assignation de tâches
/// Affiche les informations détaillées sur les tâches disponibles
class DebugTaskAssignmentWidget extends StatefulWidget {
  final User user;
  final DayOfWeek currentDay;

  const DebugTaskAssignmentWidget({
    Key? key,
    required this.user,
    required this.currentDay,
  }) : super(key: key);

  @override
  State<DebugTaskAssignmentWidget> createState() => _DebugTaskAssignmentWidgetState();
}

class _DebugTaskAssignmentWidgetState extends State<DebugTaskAssignmentWidget> {
  bool _showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataManager, LocalizationService>(
      builder: (context, dataManager, localizationService, child) {
        final allTasks = dataManager.tasks;
        final unassignedTasks = dataManager.tasks.where((task) => task.assignedTo == null).toList();
        final assignedTasks = dataManager.tasks.where((task) => task.assignedTo != null).toList();
        final userTasks = dataManager.getTasksForUser(widget.user.id, widget.currentDay);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: SpaceColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SpaceColors.starYellow.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec bouton de débogage
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SpaceColors.starYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: SpaceColors.starYellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizationService.missionOrders,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SpaceColors.starWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: _showDebugInfo,
                    onChanged: (value) {
                      setState(() {
                        _showDebugInfo = value;
                      });
                    },
                    activeColor: SpaceColors.starYellow,
                  ),
                ],
              ),
              
              if (_showDebugInfo) ...[
                const SizedBox(height: 16),
                Divider(color: SpaceColors.starWhiteSecondary.withOpacity(0.3)),
                const SizedBox(height: 16),
                
                // Statistiques
                _buildDebugSection(
                  localizationService.systemStatistics,
                  [
                    '${localizationService.totalTasksCount}: ${allTasks.length}',
                    '${localizationService.unassignedTasks}: ${unassignedTasks.length}',
                    '${localizationService.assignedTasks}: ${assignedTasks.length}',
                    '${localizationService.getTasksForUser(widget.user.name)}: ${userTasks.length}',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tâches non assignées détaillées
                _buildDebugSection(
                  localizationService.availableTasksForAssignment,
                  unassignedTasks.map((task) => 
                    '${task.title} - ${task.category} - ${localizationService.days}: ${task.assignedDays.map((d) => d.getName(localizationService.isFrench)).join(', ')}'
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Actions de test
                _buildTestActions(dataManager, localizationService),
              ],
              
              // Toujours afficher un résumé simple
              if (!_showDebugInfo) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        localizationService.availableTasks,
                        unassignedTasks.length.toString(),
                        Icons.task_alt,
                        SpaceColors.nebulaPink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        localizationService.assignedTasks,
                        assignedTasks.length.toString(),
                        Icons.assignment_turned_in,
                        SpaceColors.galaxyGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: SpaceColors.starYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SpaceColors.spaceBlack.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: SpaceColors.starWhiteSecondary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceColors.starWhiteSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SpaceColors.starWhiteSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestActions(DataManager dataManager, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.testActions,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: SpaceColors.starYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTestButton(
              localizationService.createTestTask,
              Icons.add_task,
              SpaceColors.galaxyGreen,
              () => _createTestTask(dataManager),
            ),
            _buildTestButton(
              localizationService.assignRandomly,
              Icons.shuffle,
              SpaceColors.nebulaPink,
              () => _assignRandomTask(dataManager),
            ),
            _buildTestButton(
              localizationService.unassignAll,
              Icons.clear_all,
              SpaceColors.cosmicBlue,
              () => _unassignAllTasks(dataManager),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: SpaceColors.starWhite),
      label: Text(
        label,
        style: TextStyle(
          color: SpaceColors.starWhite,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  void _createTestTask(DataManager dataManager) {
    final testTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Tâche Test ${DateTime.now().second}',
      description: 'Tâche créée pour tester l\'assignation',
      icon: Icons.star,
      iconColor: SpaceColors.starYellow,
      assignedDays: DayOfWeek.values,
      category: 'Test',
    );
    
    dataManager.addTask(testTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tâche test créée: ${testTask.title}'),
        backgroundColor: SpaceColors.galaxyGreen,
      ),
    );
  }

  void _assignRandomTask(DataManager dataManager) {
    final unassignedTasks = dataManager.tasks.where((task) => task.assignedTo == null).toList();
    
    if (unassignedTasks.isNotEmpty) {
      final randomTask = unassignedTasks.first;
      final updatedTask = randomTask.copyWith(assignedTo: widget.user.id);
      dataManager.updateTask(updatedTask);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tâche "${randomTask.title}" assignée à ${widget.user.name}'),
          backgroundColor: SpaceColors.nebulaPink,
        ),
      );
    }
  }

  void _unassignAllTasks(DataManager dataManager) {
    for (final task in dataManager.tasks) {
      if (task.assignedTo != null) {
        final updatedTask = task.copyWith(assignedTo: null);
        dataManager.updateTask(updatedTask);
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les tâches ont été désassignées'),
        backgroundColor: SpaceColors.cosmicBlue,
      ),
    );
  }
}