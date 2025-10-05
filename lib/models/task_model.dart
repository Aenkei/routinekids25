import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum TimePeriod { morning, evening, both }

extension DayOfWeekExtension on DayOfWeek {
  String getName(bool isFrench) {
    if (isFrench) {
      switch (this) {
        case DayOfWeek.monday:
          return 'Lundi';
        case DayOfWeek.tuesday:
          return 'Mardi';
        case DayOfWeek.wednesday:
          return 'Mercredi';
        case DayOfWeek.thursday:
          return 'Jeudi';
        case DayOfWeek.friday:
          return 'Vendredi';
        case DayOfWeek.saturday:
          return 'Samedi';
        case DayOfWeek.sunday:
          return 'Dimanche';
      }
    } else {
      switch (this) {
        case DayOfWeek.monday:
          return 'Monday';
        case DayOfWeek.tuesday:
          return 'Tuesday';
        case DayOfWeek.wednesday:
          return 'Wednesday';
        case DayOfWeek.thursday:
          return 'Thursday';
        case DayOfWeek.friday:
          return 'Friday';
        case DayOfWeek.saturday:
          return 'Saturday';
        case DayOfWeek.sunday:
          return 'Sunday';
      }
    }
  }
  
  String getShortName(bool isFrench) {
    if (isFrench) {
      switch (this) {
        case DayOfWeek.monday:
          return 'Lun';
        case DayOfWeek.tuesday:
          return 'Mar';
        case DayOfWeek.wednesday:
          return 'Mer';
        case DayOfWeek.thursday:
          return 'Jeu';
        case DayOfWeek.friday:
          return 'Ven';
        case DayOfWeek.saturday:
          return 'Sam';
        case DayOfWeek.sunday:
          return 'Dim';
      }
    } else {
      switch (this) {
        case DayOfWeek.monday:
          return 'Mon';
        case DayOfWeek.tuesday:
          return 'Tue';
        case DayOfWeek.wednesday:
          return 'Wed';
        case DayOfWeek.thursday:
          return 'Thu';
        case DayOfWeek.friday:
          return 'Fri';
        case DayOfWeek.saturday:
          return 'Sat';
        case DayOfWeek.sunday:
          return 'Sun';
      }
    }
  }
  
  // Backward compatibility - these will be used by default in English contexts
  String get name => getName(false);
  String get shortName => getShortName(false);
  
  int get index {
    switch (this) {
      case DayOfWeek.monday:
        return 0;
      case DayOfWeek.tuesday:
        return 1;
      case DayOfWeek.wednesday:
        return 2;
      case DayOfWeek.thursday:
        return 3;
      case DayOfWeek.friday:
        return 4;
      case DayOfWeek.saturday:
        return 5;
      case DayOfWeek.sunday:
        return 6;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<DayOfWeek> assignedDays;
  final Map<DayOfWeek, bool> completionStatus;
  String? assignedTo; // User ID
  final DateTime createdAt;
  final String category;
  final int estimatedMinutes;
  final TimePeriod timePeriod;
  final Uint8List? customImage; // Custom image for the task

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.icon,
    required this.iconColor,
    required this.assignedDays,
    Map<DayOfWeek, bool>? completionStatus,
    this.assignedTo,
    DateTime? createdAt,
    this.category = 'General',
    this.estimatedMinutes = 15,
    this.timePeriod = TimePeriod.both,
    this.customImage,
  }) : completionStatus = completionStatus ?? _initializeCompletionStatus(assignedDays),
       createdAt = createdAt ?? DateTime.now();

  static Map<DayOfWeek, bool> _initializeCompletionStatus(List<DayOfWeek> days) {
    final Map<DayOfWeek, bool> status = {};
    for (final day in days) {
      status[day] = false;
    }
    return status;
  }

  // Check if task is completed for a specific day
  bool isCompletedForDay(DayOfWeek day) {
    return completionStatus[day] ?? false;
  }

  // Toggle completion for a specific day
  Task toggleCompletionForDay(DayOfWeek day) {
    final newStatus = Map<DayOfWeek, bool>.from(completionStatus);
    newStatus[day] = !(newStatus[day] ?? false);
    
    return Task(
      id: id,
      title: title,
      description: description,
      icon: icon,
      iconColor: iconColor,
      assignedDays: assignedDays,
      completionStatus: newStatus,
      assignedTo: assignedTo,
      createdAt: createdAt,
      category: category,
      estimatedMinutes: estimatedMinutes,
      timePeriod: timePeriod,
      customImage: customImage, // Preserve custom image!
    );
  }

  // Get completion percentage for this task
  double get completionPercentage {
    if (assignedDays.isEmpty) return 0.0;
    final completedCount = assignedDays.where((day) => isCompletedForDay(day)).length;
    return completedCount / assignedDays.length;
  }

  // Check if task is assigned to a specific day
  bool isAssignedToDay(DayOfWeek day) {
    return assignedDays.contains(day);
  }

  // Get today\'s day of week
  static DayOfWeek get today {
    final now = DateTime.now();
    return DayOfWeek.values[now.weekday - 1]; // DateTime.weekday is 1-7, our enum is 0-6
  }

  // Check if task is scheduled for today
  bool get isScheduledToday {
    return isAssignedToDay(today);
  }

  // Check if task is completed today
  bool get isCompletedToday {
    return isCompletedForDay(today);
  }

  // Copy task with new values
  Task copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? iconColor,
    List<DayOfWeek>? assignedDays,
    Map<DayOfWeek, bool>? completionStatus,
    String? assignedTo,
    DateTime? createdAt,
    String? category,
    int? estimatedMinutes,
    TimePeriod? timePeriod,
    Uint8List? customImage,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      assignedDays: assignedDays ?? this.assignedDays,
      completionStatus: completionStatus ?? this.completionStatus,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      timePeriod: timePeriod ?? this.timePeriod,
      customImage: customImage ?? this.customImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon.codePoint,
        'iconColor': iconColor.value,
        'assignedDays': assignedDays.map((day) => day.index).toList(),
        'completionStatus': completionStatus.map(
          (key, value) => MapEntry(key.index.toString(), value),
        ),
        'assignedTo': assignedTo,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'category': category,
        'estimatedMinutes': estimatedMinutes,
        'timePeriod': timePeriod.index,
        'customImage': customImage != null ? base64Encode(customImage!) : null,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final assignedDays = (json['assignedDays'] as List<dynamic>)
        .map((dayIndex) => DayOfWeek.values[dayIndex as int])
        .toList();
    
    final completionStatusMap = (json['completionStatus'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(
          DayOfWeek.values[int.parse(key)],
          value as bool,
        ));

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(json['iconColor'] as int),
      assignedDays: assignedDays,
      completionStatus: completionStatusMap,
      assignedTo: json['assignedTo'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      category: json['category'] as String? ?? 'General',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      timePeriod: json['timePeriod'] != null ? TimePeriod.values[json['timePeriod'] as int] : TimePeriod.both,
      customImage: json['customImage'] != null ? base64Decode(json['customImage'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Task categories with icons and colors
class TaskCategory {
  final String englishName;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.englishName,
    required this.icon,
    required this.color,
  });

  static const List<TaskCategory> categories = [
    TaskCategory(englishName: 'Personal Care', icon: Icons.self_improvement, color: Color(0xFF4FC3F7)),
    TaskCategory(englishName: 'School & Study', icon: Icons.school, color: Color(0xFF66BB6A)),
    TaskCategory(englishName: 'Chores', icon: Icons.cleaning_services, color: Color(0xFFFFB74D)),
    TaskCategory(englishName: 'Health & Fitness', icon: Icons.fitness_center, color: Color(0xFFFF8A65)),
    TaskCategory(englishName: 'Creative', icon: Icons.palette, color: Color(0xFFBA68C8)),
    TaskCategory(englishName: 'General', icon: Icons.task_alt, color: Color(0xFF90A4AE)),
  ];
}