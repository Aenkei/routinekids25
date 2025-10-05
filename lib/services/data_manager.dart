import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:dreamflow/models/task_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'package:dreamflow/theme.dart';

class DataManager extends ChangeNotifier {
  final SharedPreferences prefs;
  final Uuid uuid = const Uuid();
  LocalizationService? _localizationService;
  PremiumManager? _premiumManager;

  List<User> _users = [];
  List<Task> _tasks = [];
  
  // Force notify all listeners
  void forceNotifyListeners() {
    notifyListeners();
    // Schedule another notification to ensure all widgets update
    Future.microtask(() {
      notifyListeners();
      // Final notification for stubborn widgets
      Future.delayed(const Duration(milliseconds: 16), () {
        notifyListeners();
      });
    });
  }
  
  // Time period settings
  int _morningStartHour = 7;
  int _morningEndHour = 12;
  int _eveningStartHour = 12;
  int _eveningEndHour = 21;
  
  // Language settings
  AppLanguage _selectedLanguage = AppLanguage.english;
  
  // Progress ring style settings - Default to Rainbow (free theme)
  String _progressRingStyle = 'rainbow'; // Default: 'rainbow' (free), Premium: 'neon', 'crystal', 'dynamic'

  List<User> get users => _users;
  List<Task> get tasks => _tasks;
  int get morningStartHour => _morningStartHour;
  int get morningEndHour => _morningEndHour;
  int get eveningStartHour => _eveningStartHour;
  int get eveningEndHour => _eveningEndHour;
  AppLanguage get selectedLanguage => _selectedLanguage;
  String get progressRingStyle => _progressRingStyle;

  DataManager(this.prefs) {
    loadData();
  }
  
  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
    _updateTaskTranslations();
    notifyListeners();
  }
  
  void setPremiumManager(PremiumManager premiumManager) {
    _premiumManager = premiumManager;
    notifyListeners();
  }

  void loadData() {
    try {
      // Load users
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users = usersList.map((json) => User.fromJson(json)).toList();
      }

      // Load tasks
      final tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
      }

      // Load time period settings
      _morningStartHour = prefs.getInt('morningStartHour') ?? 7;
      _morningEndHour = prefs.getInt('morningEndHour') ?? 12;
      _eveningStartHour = prefs.getInt('eveningStartHour') ?? 12;
      _eveningEndHour = prefs.getInt('eveningEndHour') ?? 21;
      
      // Load language settings
      final languageIndex = prefs.getInt('selectedLanguage') ?? 0;
      _selectedLanguage = AppLanguage.values[languageIndex];
      
      // Update localization service if available
      if (_localizationService != null) {
        _localizationService!.setLanguage(_selectedLanguage);
      }
      
      // Load progress ring style
      _progressRingStyle = prefs.getString('progressRingStyle') ?? 'neon';
      
      // If no data exists, add sample tasks but no users (for onboarding flow)
      if (_users.isEmpty && _tasks.isEmpty) {
        _addSampleData();
      }
      
      notifyListeners();
    } catch (e) {
      // If loading fails, start with empty data
      _users = [];
      _tasks = [];
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    final usersJson = jsonEncode(_users.map((user) => user.toJson()).toList());
    final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('users', usersJson);
    await prefs.setString('tasks', tasksJson);
    await prefs.setInt('selectedLanguage', _selectedLanguage.index);
    await prefs.setString('progressRingStyle', _progressRingStyle);
  }

  // Time period management
  void updateTimePeriods({
    int? morningStart,
    int? morningEnd,
    int? eveningStart,
    int? eveningEnd,
  }) {
    if (morningStart != null) _morningStartHour = morningStart;
    if (morningEnd != null) _morningEndHour = morningEnd;
    if (eveningStart != null) _eveningStartHour = eveningStart;
    if (eveningEnd != null) _eveningEndHour = eveningEnd;
    saveData();
    forceNotifyListeners();
  }
  
  // Language management
  void updateLanguage(AppLanguage language) {
    _selectedLanguage = language;
    _updateTaskTranslations();
    saveData();
    forceNotifyListeners();
  }
  
  // Progress ring style management
  void updateProgressRingStyle(String style) {
    _progressRingStyle = style;
    saveData();
    forceNotifyListeners();
  }
  
  void _updateTaskTranslations() {
    if (_localizationService == null) return;
    
    // Update existing task titles and descriptions
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final updatedTask = task.copyWith(
        title: _localizationService!.getTaskTitle(_getEnglishTitle(task.title)),
        description: _localizationService!.getTaskDescription(_getEnglishDescription(task.description)),
        category: _localizationService!.getCategoryName(_getEnglishCategory(task.category)),
      );
      _tasks[i] = updatedTask;
    }
    notifyListeners();
  }
  
  // Helper methods to get original English text for reverse translation
  String _getEnglishTitle(String localizedTitle) {
    // Map common French titles back to English for retranslation
    final frenchToEnglish = {
      'Se brosser les dents': 'Brush Teeth',
      'Prendre une douche': 'Take a Shower',
      'Se laver le visage': 'Wash Face',
      'Se coiffer': 'Comb Hair',
      'S\'habiller': 'Get Dressed',
      'Se brosser les dents (Soir)': 'Brush Teeth (Evening)',
      'Faire son lit': 'Make Bed',
      'Nourrir l\'animal': 'Feed Pet',
      'Mettre la table': 'Set Dining Table',
      'Arroser les plantes': 'Water Plants',
      'Sortir les poubelles': 'Take Out Trash',
      'Ranger les jouets': 'Organize Toys',
      'Charger le lave-vaisselle': 'Load Dishwasher',
      'Ranger sa chambre': 'Tidy Room',
      'Aider à préparer le petit-déjeuner': 'Help Cook Breakfast',
      'Exercice matinal': 'Morning Exercise',
      'Boire de l\'eau': 'Drink Water',
      'Prendre des vitamines': 'Take Vitamins',
      'Faire une promenade': 'Go for a Walk',
      'Jouer dehors': 'Outdoor Play',
      'Faire ses devoirs': 'Complete Homework',
      'Préparer son cartable': 'Pack School Bag',
      'Pratiquer la musique': 'Practice Music',
      'Réviser pour un contrôle': 'Study for Test',
      'Lire un livre': 'Read Book',
      'Dessiner ou peindre': 'Draw or Paint',
      'Écrire dans son journal': 'Write in Journal',
      'Construire avec des blocs': 'Build with Blocks',
      'Préparer les vêtements de demain': 'Prepare Tomorrow\'s Clothes',
      'Réfléchir à sa journée': 'Review Day',
      'Temps de jeu en famille': 'Family Game Time',
    };
    return frenchToEnglish[localizedTitle] ?? localizedTitle;
  }
  
  String _getEnglishDescription(String localizedDescription) {
    // For descriptions, return original if it's already English
    return localizedDescription;
  }
  
  String _getEnglishCategory(String localizedCategory) {
    final frenchToEnglish = {
      'Soins personnels': 'Personal Care',
      'École & Études': 'School & Study',
      'Corvées': 'Chores',
      'Santé & Forme': 'Health & Fitness',
      'Créatif': 'Creative',
      'Général': 'General',
    };
    return frenchToEnglish[localizedCategory] ?? localizedCategory;
  }

  bool isCurrentlyMorning() {
    final now = DateTime.now();
    return now.hour >= _morningStartHour && now.hour < _morningEndHour;
  }

  bool isCurrentlyEvening() {
    final now = DateTime.now();
    return now.hour >= _eveningStartHour && now.hour <= _eveningEndHour;
  }

  Task _createLocalizedTask({
    required String englishTitle,
    required String englishDescription,
    required IconData icon,
    required Color iconColor,
    required List<DayOfWeek> assignedDays,
    required String englishCategory,
    String? assignedTo,
    int estimatedMinutes = 15,
    TimePeriod timePeriod = TimePeriod.both,
  }) {
    final localization = _localizationService;
    return Task(
      id: uuid.v4(),
      title: localization?.getTaskTitle(englishTitle) ?? englishTitle,
      description: localization?.getTaskDescription(englishDescription) ?? englishDescription,
      icon: icon,
      iconColor: iconColor,
      assignedDays: assignedDays,
      assignedTo: assignedTo,
      category: localization?.getCategoryName(englishCategory) ?? englishCategory,
      estimatedMinutes: estimatedMinutes,
      timePeriod: timePeriod,
    );
  }

  void _addSampleData() {
    // Ajouter un petit assortiment de tâches d'exemple attrayantes
    // pour montrer le potentiel de l'application (5 tâches variées)
    
    final exampleTasks = [
      // Tâche du matin - Soins personnels
      _createLocalizedTask(
        englishTitle: 'Brush Teeth',
        englishDescription: 'Start the day with fresh breath and healthy teeth',
        icon: Icons.clean_hands,
        iconColor: SpaceColors.cosmicBlue,
        assignedDays: DayOfWeek.values, // Tous les jours
        englishCategory: 'Personal Care',
        estimatedMinutes: 5,
        timePeriod: TimePeriod.morning,
        // Non assignée - disponible pour assignation
      ),
      
      // Tâche quotidienne - Corvée facile
      _createLocalizedTask(
        englishTitle: 'Make Bed',
        englishDescription: 'Tidy up bedroom and start the day organized',
        icon: Icons.bed,
        iconColor: SpaceColors.nebulaPink,
        assignedDays: DayOfWeek.values,
        englishCategory: 'Chores',
        estimatedMinutes: 5,
        timePeriod: TimePeriod.morning,
        // Non assignée - disponible pour assignation
      ),
      
      // Tâche scolaire - Weekdays
      _createLocalizedTask(
        englishTitle: 'Complete Homework',
        englishDescription: 'Finish daily school assignments and review lessons',
        icon: Icons.assignment,
        iconColor: SpaceColors.starYellow,
        assignedDays: [DayOfWeek.monday, DayOfWeek.tuesday, DayOfWeek.wednesday, DayOfWeek.thursday, DayOfWeek.friday],
        englishCategory: 'School & Study',
        estimatedMinutes: 30,
        timePeriod: TimePeriod.evening,
        // Non assignée - disponible pour assignation
      ),
      
      // Tâche créative - Week-end
      _createLocalizedTask(
        englishTitle: 'Read Book',
        englishDescription: 'Enjoy a good story and expand imagination',
        icon: Icons.menu_book,
        iconColor: SpaceColors.galaxyGreen,
        assignedDays: [DayOfWeek.saturday, DayOfWeek.sunday],
        englishCategory: 'Creative',
        estimatedMinutes: 20,
        timePeriod: TimePeriod.both,
        // Non assignée - disponible pour assignation
      ),
      
      // Tâche du soir - Routine apaisante
      _createLocalizedTask(
        englishTitle: 'Tidy Room',
        englishDescription: 'Organize personal space for a peaceful night',
        icon: Icons.cleaning_services,
        iconColor: const Color(0xFF9c88ff),
        assignedDays: DayOfWeek.values,
        englishCategory: 'Chores',
        estimatedMinutes: 10,
        timePeriod: TimePeriod.evening,
        // Non assignée - disponible pour assignation
      ),
    ];

    _tasks = exampleTasks;
    notifyListeners();
    saveData();
    
    // No users created - they will be added through onboarding
    return;
  }

  // User management
  void addUser(User user) {
    // Vérification de la limite premium
    if (_premiumManager != null && !_premiumManager!.canAddUser(_users.length)) {
      throw PremiumLimitationException(PremiumLimitationType.users);
    }
    
    _users.add(user);
    saveData();
    forceNotifyListeners();
  }

  void updateUser(User user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      saveData();
      forceNotifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    // Also remove user assignments from tasks
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].assignedTo == userId) {
        _tasks[i] = _tasks[i].copyWith(assignedTo: null);
      }
    }
    saveData();
    forceNotifyListeners();
  }

  // Task management
  void addTask(Task task) {
    // Vérification de la limite premium
    if (_premiumManager != null && !_premiumManager!.canAddTask(_tasks.length)) {
      throw PremiumLimitationException(PremiumLimitationType.tasks);
    }
    
    // Traduire la tâche selon la langue actuelle
    if (_localizationService != null) {
      final localizedTask = _createLocalizedTask(
        englishTitle: task.title,
        englishDescription: task.description,
        icon: task.icon,
        iconColor: task.iconColor,
        assignedDays: task.assignedDays,
        englishCategory: task.category,
        assignedTo: task.assignedTo,
        estimatedMinutes: task.estimatedMinutes,
        timePeriod: task.timePeriod,
      );
      _tasks.add(localizedTask.copyWith(id: task.id, customImage: task.customImage));
    } else {
      _tasks.add(task);
    }
    saveData();
    forceNotifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      saveData();
      forceNotifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    saveData();
    forceNotifyListeners();
  }

  void completeTask(String taskId, DayOfWeek day) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedTask = task.toggleCompletionForDay(day);
      _tasks[taskIndex] = updatedTask;
      
      // Update user statistics if task is assigned
      if (task.assignedTo != null) {
        final userIndex = _users.indexWhere((user) => user.id == task.assignedTo);
        if (userIndex != -1) {
          final user = _users[userIndex];
          final updatedUser = user.updateWeeklyProgress(1);
          _users[userIndex] = updatedUser;
        }
      }
      
      saveData();
      forceNotifyListeners();
    }
  }

  void resetProgress() {
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final resetCompletionStatus = <DayOfWeek, bool>{};
      for (final day in task.assignedDays) {
        resetCompletionStatus[day] = false;
      }
      _tasks[i] = task.copyWith(completionStatus: resetCompletionStatus);
    }
    
    // Reset user statistics
    for (int i = 0; i < _users.length; i++) {
      _users[i] = _users[i].copyWith(
        currentStreak: 0,
        weeklyProgress: {},
      );
    }
    
    saveData();
    forceNotifyListeners();
  }

  // Query methods
  List<Task> getTasksForUser(String userId, DayOfWeek day) {
    return _tasks.where((task) => 
      task.assignedTo == userId && task.isAssignedToDay(day)
    ).toList();
  }

  List<Task> getTasksForUserByPeriod(String userId, DayOfWeek day, String timePeriod) {
    return _tasks.where((task) => 
      task.assignedTo == userId && 
      task.isAssignedToDay(day) &&
      _isTaskForTimePeriod(task, timePeriod)
    ).toList();
  }

  List<Task> getUnassignedTasks(DayOfWeek day) {
    return _tasks.where((task) => 
      task.assignedTo == null && task.isAssignedToDay(day)
    ).toList();
  }
  
  // Méthode pour obtenir toutes les tâches non assignées (pour l'assignation)
  List<Task> getAllUnassignedTasks() {
    return _tasks.where((task) => task.assignedTo == null).toList();
  }

  List<Task> getAllTasksForDay(DayOfWeek day) {
    return _tasks.where((task) => task.isAssignedToDay(day)).toList();
  }

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  bool _isTaskForTimePeriod(Task task, String timePeriod) {
    switch (timePeriod) {
      case 'morning':
        return task.timePeriod == TimePeriod.morning || task.timePeriod == TimePeriod.both;
      case 'evening':
        return task.timePeriod == TimePeriod.evening || task.timePeriod == TimePeriod.both;
      case 'current':
        // Show tasks based on current time
        if (isCurrentlyMorning()) {
          return task.timePeriod == TimePeriod.morning || task.timePeriod == TimePeriod.both;
        } else {
          return task.timePeriod == TimePeriod.evening || task.timePeriod == TimePeriod.both;
        }
      default:
        return true; // Show all tasks if no specific period is selected
    }
  }

  // Analytics and statistics
  Map<String, int> getWeeklyCompletionStats() {
    final stats = <String, int>{};
    
    for (final day in DayOfWeek.values) {
      final dayTasks = getAllTasksForDay(day);
      final completedCount = dayTasks.where((task) => 
        task.isCompletedForDay(day)
      ).length;
      stats[day.name] = completedCount;
    }
    
    return stats;
  }

  double getOverallCompletionRate() {
    if (_tasks.isEmpty) return 0.0;
    
    int totalPossibleCompletions = 0;
    int actualCompletions = 0;
    
    for (final task in _tasks) {
      totalPossibleCompletions += task.assignedDays.length;
      actualCompletions += task.assignedDays.where((day) => 
        task.isCompletedForDay(day)
      ).length;
    }
    
    return totalPossibleCompletions > 0 ? actualCompletions / totalPossibleCompletions : 0.0;
  }

  List<User> getTopPerformers() {
    final sortedUsers = List<User>.from(_users);
    sortedUsers.sort((a, b) => b.totalTasksCompleted.compareTo(a.totalTasksCompleted));
    return sortedUsers.take(3).toList();
  }

  // Achievement system
  void updateUserAchievements(String userId) {
    final userIndex = _users.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final userTasks = _tasks.where((task) => task.assignedTo == userId).toList();
      final updatedUser = user.checkAndUpdateAchievements(userTasks);
      _users[userIndex] = updatedUser;
      saveData();
      notifyListeners();
    }
  }

  // Data export and import (for future use)
  Map<String, dynamic> exportData() {
    return {
      'users': _users.map((u) => u.toJson()).toList(),
      'tasks': _tasks.map((t) => t.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  void importData(Map<String, dynamic> data) {
    try {
      if (data['users'] != null) {
        _users = (data['users'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
      }
      
      if (data['tasks'] != null) {
        _tasks = (data['tasks'] as List)
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();
      }
      
      saveData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
    }
  }
  
  // Premium management
  bool canAddUser() {
    return _premiumManager?.canAddUser(_users.length) ?? true;
  }
  
  bool canAddTask() {
    return _premiumManager?.canAddTask(_tasks.length) ?? true;
  }
  
  bool canUseProgressStyle(String style) {
    return _premiumManager?.canUseProgressStyle(style) ?? true;
  }
  
  PremiumLimitationInfo? getPremiumLimitationInfo() {
    return _premiumManager?.getLimitationInfo(_users.length, _tasks.length);
  }
}

/// Exception lancée quand une limitation premium est atteinte
class PremiumLimitationException implements Exception {
  final PremiumLimitationType type;
  
  const PremiumLimitationException(this.type);
  
  @override
  String toString() {
    switch (type) {
      case PremiumLimitationType.users:
        return 'Premium required to add more users';
      case PremiumLimitationType.tasks:
        return 'Premium required to add more tasks';
      case PremiumLimitationType.progressStyles:
        return 'Premium required for this progress style';
    }
  }
}