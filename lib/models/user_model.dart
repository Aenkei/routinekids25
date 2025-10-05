import 'dart:convert';
import 'dart:typed_data';
import 'package:dreamflow/models/task_model.dart';

class User {
  final String id;
  String name;
  Uint8List? profilePicture;
  final DateTime createdAt;
  int currentStreak;
  int longestStreak;
  Map<String, int> weeklyProgress; // Week key -> completed tasks count
  int totalTasksCompleted;
  String favoriteCategory;
  List<String> achievements;

  User({
    required this.id,
    required this.name,
    this.profilePicture,
    DateTime? createdAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    Map<String, int>? weeklyProgress,
    this.totalTasksCompleted = 0,
    this.favoriteCategory = 'General',
    List<String>? achievements,
  }) : createdAt = createdAt ?? DateTime.now(),
       weeklyProgress = weeklyProgress ?? {},
       achievements = achievements ?? [];

  // Get current week key (format: yyyy-ww)
  static String getCurrentWeekKey() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final weekOfYear = ((dayOfYear - now.weekday + 10) / 7).floor();
    return '${now.year}-${weekOfYear.toString().padLeft(2, '0')}';
  }

  // Get tasks completed this week
  int get tasksCompletedThisWeek {
    return weeklyProgress[getCurrentWeekKey()] ?? 0;
  }

  // Update weekly progress
  User updateWeeklyProgress(int completedTasks) {
    final weekKey = getCurrentWeekKey();
    final newProgress = Map<String, int>.from(weeklyProgress);
    newProgress[weekKey] = completedTasks;
    
    return copyWith(
      weeklyProgress: newProgress,
      totalTasksCompleted: totalTasksCompleted + 1,
    );
  }

  // Calculate completion rate for a specific week
  double getCompletionRateForWeek(List<Task> userTasks, String weekKey) {
    if (userTasks.isEmpty) return 0.0;
    
    // Calculate total possible completions for the week
    int totalPossible = 0;
    for (final task in userTasks) {
      totalPossible += task.assignedDays.length;
    }
    
    if (totalPossible == 0) return 0.0;
    
    final completed = weeklyProgress[weekKey] ?? 0;
    return completed / totalPossible;
  }

  // Get level based on total tasks completed
  int get level {
    return (totalTasksCompleted / 50).floor() + 1;
  }

  // Get progress to next level
  double get progressToNextLevel {
    final currentLevelBase = (level - 1) * 50;
    final nextLevelBase = level * 50;
    final progress = totalTasksCompleted - currentLevelBase;
    return progress / (nextLevelBase - currentLevelBase);
  }

  // Check and update achievements
  User checkAndUpdateAchievements(List<Task> userTasks) {
    final newAchievements = List<String>.from(achievements);
    
    // First task completion
    if (totalTasksCompleted >= 1 && !achievements.contains('first_task')) {
      newAchievements.add('first_task');
    }
    
    // Week warrior (complete all tasks for a week)
    if (getCompletionRateForWeek(userTasks, getCurrentWeekKey()) >= 1.0 && 
        !achievements.contains('week_warrior')) {
      newAchievements.add('week_warrior');
    }
    
    // Streak master (7 day streak)
    if (currentStreak >= 7 && !achievements.contains('streak_master')) {
      newAchievements.add('streak_master');
    }
    
    // Century club (100 tasks)
    if (totalTasksCompleted >= 100 && !achievements.contains('century_club')) {
      newAchievements.add('century_club');
    }
    
    // Early bird (complete morning tasks)
    if (!achievements.contains('early_bird')) {
      final morningTasks = userTasks.where((task) => 
        task.category == 'Morning' && task.isCompletedToday
      );
      if (morningTasks.isNotEmpty) {
        newAchievements.add('early_bird');
      }
    }
    
    return copyWith(achievements: newAchievements);
  }

  // Update streak based on task completion
  User updateStreak(bool completedTasksToday) {
    if (completedTasksToday) {
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      );
    } else {
      return copyWith(currentStreak: 0);
    }
  }

  // Copy user with new values
  User copyWith({
    String? id,
    String? name,
    Uint8List? profilePicture,
    DateTime? createdAt,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? weeklyProgress,
    int? totalTasksCompleted,
    String? favoriteCategory,
    List<String>? achievements,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      favoriteCategory: favoriteCategory ?? this.favoriteCategory,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'profilePicture': profilePicture != null ? base64Encode(profilePicture!) : null,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'weeklyProgress': weeklyProgress,
        'totalTasksCompleted': totalTasksCompleted,
        'favoriteCategory': favoriteCategory,
        'achievements': achievements,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        profilePicture: json['profilePicture'] != null 
            ? base64Decode(json['profilePicture'] as String) 
            : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        weeklyProgress: Map<String, int>.from(json['weeklyProgress'] as Map? ?? {}),
        totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
        favoriteCategory: json['favoriteCategory'] as String? ?? 'General',
        achievements: List<String>.from(json['achievements'] as List? ?? []),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Achievement definitions
class Achievement {
  final String id;
  final String englishTitle;
  final String englishDescription;
  final String icon;
  final bool isRare;

  const Achievement({
    required this.id,
    required this.englishTitle,
    required this.englishDescription,
    required this.icon,
    this.isRare = false,
  });

  static const List<Achievement> achievements = [
    Achievement(
      id: 'first_task',
      englishTitle: 'First Steps',
      englishDescription: 'Complete your first task',
      icon: '🌟',
    ),
    Achievement(
      id: 'week_warrior',
      englishTitle: 'Week Warrior',
      englishDescription: 'Complete all tasks for an entire week',
      icon: '⚔️',
      isRare: true,
    ),
    Achievement(
      id: 'streak_master',
      englishTitle: 'Streak Master',
      englishDescription: 'Maintain a 7-day completion streak',
      icon: '🔥',
      isRare: true,
    ),
    Achievement(
      id: 'century_club',
      englishTitle: 'Century Club',
      englishDescription: 'Complete 100 tasks total',
      icon: '💯',
      isRare: true,
    ),
    Achievement(
      id: 'early_bird',
      englishTitle: 'Early Bird',
      englishDescription: 'Complete morning routine tasks',
      icon: '🐦',
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return achievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}