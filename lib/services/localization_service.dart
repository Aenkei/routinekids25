import 'package:flutter/material.dart';

enum AppLanguage { english, french }

class LocalizationService extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  
  AppLanguage get currentLanguage => _currentLanguage;
  bool get isFrench => _currentLanguage == AppLanguage.french;
  bool get isEnglish => _currentLanguage == AppLanguage.english;
  
  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }
  
  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
    }
  }
  
  // Main Navigation
  String get settings => isFrench ? 'Paramètres' : 'Settings';
  String get home => isFrench ? 'Accueil' : 'Home';
  String get back => isFrench ? 'Retour' : 'Back';
  
  // Time of Day
  String get morning => isFrench ? 'Matin' : 'Morning';
  String get afternoon => isFrench ? 'Après-midi' : 'Afternoon';
  String get evening => isFrench ? 'Soir' : 'Evening';
  String get current => isFrench ? 'Actuel' : 'Current';
  String get both => isFrench ? 'Les deux' : 'Both';
  String get timePeriod => isFrench ? 'Période' : 'Time Period';
  String get selectTimePeriod => isFrench ? 'Sélectionner la période' : 'Select time period';
  
  // Days of Week
  String get monday => isFrench ? 'Lundi' : 'Monday';
  String get tuesday => isFrench ? 'Mardi' : 'Tuesday';
  String get wednesday => isFrench ? 'Mercredi' : 'Wednesday';
  String get thursday => isFrench ? 'Jeudi' : 'Thursday';
  String get friday => isFrench ? 'Vendredi' : 'Friday';
  String get saturday => isFrench ? 'Samedi' : 'Saturday';
  String get sunday => isFrench ? 'Dimanche' : 'Sunday';
  
  String getDayName(int dayIndex) {
    switch (dayIndex) {
      case 0: return monday;
      case 1: return tuesday;
      case 2: return wednesday;
      case 3: return thursday;
      case 4: return friday;
      case 5: return saturday;
      case 6: return sunday;
      default: return monday;
    }
  }
  
  // Short day names
  String get mondayShort => isFrench ? 'Lun' : 'Mon';
  String get tuesdayShort => isFrench ? 'Mar' : 'Tue';
  String get wednesdayShort => isFrench ? 'Mer' : 'Wed';
  String get thursdayShort => isFrench ? 'Jeu' : 'Thu';
  String get fridayShort => isFrench ? 'Ven' : 'Fri';
  String get saturdayShort => isFrench ? 'Sam' : 'Sat';
  String get sundayShort => isFrench ? 'Dim' : 'Sun';
  
  String getDayShortName(int dayIndex) {
    switch (dayIndex) {
      case 0: return mondayShort;
      case 1: return tuesdayShort;
      case 2: return wednesdayShort;
      case 3: return thursdayShort;
      case 4: return fridayShort;
      case 5: return saturdayShort;
      case 6: return sundayShort;
      default: return mondayShort;
    }
  }
  
  // Month names
  String getMonthName(int month) {
    if (isFrench) {
      const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                     'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return months[month - 1];
    } else {
      const months = ['January', 'February', 'March', 'April', 'May', 'June',
                     'July', 'August', 'September', 'October', 'November', 'December'];
      return months[month - 1];
    }
  }
  
  // Greetings
  String get goodMorning => isFrench ? 'Bonjour' : 'Good Morning';
  String get goodAfternoon => isFrench ? 'Bon après-midi' : 'Good Afternoon';
  String get goodEvening => isFrench ? 'Bonsoir' : 'Good Evening';
  
  // Tasks
  String get tasks => isFrench ? 'Tâches' : 'Tasks';
  String get task => isFrench ? 'Tâche' : 'Task';
  String get newTask => isFrench ? 'Nouvelle tâche' : 'New Task';
  String get assignTask => isFrench ? 'Assigner tâche' : 'Assign Task';
  String get assignTasks => isFrench ? 'Assigner des tâches' : 'Assign Tasks';
  String get availableTasks => isFrench ? 'Tâches disponibles' : 'Available Tasks';
  String get completedTasks => isFrench ? 'Tâches terminées' : 'Completed Tasks';
  String get taskTitle => isFrench ? 'Titre de la tâche' : 'Task Title';
  String get taskDescription => isFrench ? 'Description de la tâche' : 'Task Description';
  String get noTasksAssigned => isFrench ? 'Aucune tâche assignée' : 'No tasks assigned';
  String get noTasksAvailable => isFrench ? 'Aucune tâche disponible' : 'No tasks available';
  String get taskCompleted => isFrench ? 'Tâche terminée!' : 'Task completed!';
  String get deleteTask => isFrench ? 'Supprimer la tâche' : 'Delete Task';
  String get editTask => isFrench ? 'Modifier la tâche' : 'Edit Task';
  String get addFirstTask => isFrench ? 'Ajouter ma première tâche' : 'Add my first task';
  
  // Task Instructions
  String getTaskAssignInstruction(String userName) => 
    isFrench ? 'Touchez une tâche pour l\'assigner à $userName' : 'Tap any task to assign it to $userName';
  
  String getTasksHeader(int count) => 
    isFrench ? 'Tâches disponibles • $count tâche${count > 1 ? 's' : ''}' : 'Available Tasks • $count task${count != 1 ? 's' : ''}';
  
  String get theseTasksNotAssigned => 
    isFrench ? 'Ces tâches ne sont assignées à personne pour le moment' : 'These tasks are not assigned to anyone yet';
  
  // Categories
  String get category => isFrench ? 'Catégorie' : 'Category';
  String get personalCare => isFrench ? 'Soins personnels' : 'Personal Care';
  String get schoolStudy => isFrench ? 'École & Études' : 'School & Study';
  String get chores => isFrench ? 'Corvées' : 'Chores';
  String get healthFitness => isFrench ? 'Santé & Forme' : 'Health & Fitness';
  String get creative => isFrench ? 'Créatif' : 'Creative';
  String get general => isFrench ? 'Général' : 'General';
  
  // Users
  String get users => isFrench ? 'Utilisateurs' : 'Users';
  String get user => isFrench ? 'Utilisateur' : 'User';
  String get addUser => isFrench ? 'Ajouter un utilisateur' : 'Add User';
  String get editUser => isFrench ? 'Modifier l\'utilisateur' : 'Edit User';
  String get deleteUser => isFrench ? 'Supprimer l\'utilisateur' : 'Delete User';
  String get userName => isFrench ? 'Nom d\'utilisateur' : 'User Name';
  String get profilePicture => isFrench ? 'Photo de profil' : 'Profile Picture';
  String get takePhoto => isFrench ? 'Prendre une photo' : 'Take Photo';
  String get chooseFromGallery => isFrench ? 'Choisir dans la galerie' : 'Choose from Gallery';
  String get noUsersYet => isFrench ? 'Aucun utilisateur pour le moment' : 'No users yet';
  
  // Actions
  String get save => isFrench ? 'Sauvegarder' : 'Save';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get delete => isFrench ? 'Supprimer' : 'Delete';
  String get edit => isFrench ? 'Modifier' : 'Edit';
  String get add => isFrench ? 'Ajouter' : 'Add';
  String get create => isFrench ? 'Créer' : 'Create';
  String get update => isFrench ? 'Mettre à jour' : 'Update';
  String get done => isFrench ? 'Terminé' : 'Done';
  String get close => isFrench ? 'Fermer' : 'Close';
  String get confirm => isFrench ? 'Confirmer' : 'Confirm';
  String get continue_ => isFrench ? 'Continuer' : 'Continue';
  
  // Settings
  String get appSettings => isFrench ? 'Paramètres de l\'application' : 'App Settings';
  String get language => isFrench ? 'Langue' : 'Language';
  String get languageSettings => isFrench ? 'Paramètres de langue' : 'Language Settings';
  String get selectLanguage => isFrench ? 'Sélectionner la langue' : 'Select Language';
  String get timePeriods => isFrench ? 'Périodes de temps' : 'Time Periods';
  String get timePeriodsSettings => isFrench ? 'Paramètres des périodes' : 'Time Period Settings';
  String get customizeTimeSettings => isFrench ? 'Personnaliser les paramètres de temps' : 'Customize time settings';
  String get userManagement => isFrench ? 'Gestion des utilisateurs' : 'User Management';
  String get taskManagement => isFrench ? 'Gestion des tâches' : 'Task Management';
  String get dataManagement => isFrench ? 'Gestion des données' : 'Data Management';
  String get about => isFrench ? 'À propos' : 'About';
  String get appInfo => isFrench ? 'Informations de l\'application et version' : 'App information and version';
  String get resetProgress => isFrench ? 'Réinitialiser les progrès' : 'Reset Progress';
  String get resetAllData => isFrench ? 'Réinitialiser toutes les données' : 'Reset all data';
  
  // About Section
  String get appVersion => isFrench ? 'RoutineKids – Version 1.0.0' : 'RoutineKids – Version 1.0.0';
  String get appDescription => isFrench ? 
    'L\'application qui rend les routines familiales simples, amusantes et motivantes.' :
    'The app that makes family routines simple, fun, and motivating.';
  String get appFeatures => isFrench ? 
    'Créez des routines personnalisées, suivez les progrès, et motivez vos enfants avec un système de récompenses ludique dans un environnement spatial magique.' :
    'Create custom routines, track progress, and motivate your children with a fun reward system in a magical space environment.';
  String get appMadeWith => isFrench ? 'Fait avec ❤️ pour les familles' : 'Made with ❤️ for families';

  // App features list
  String get customizableThemes => isFrench ? 'Thèmes visuels personnalisables' : 'Customizable visual themes';
  String get funAnimations => isFrench ? 'Animations amusantes et motivantes' : 'Fun and motivating animations';
  String get secureAccess => isFrench ? 'Accès sécurisé réservé aux parents' : 'Secure parent-only access to settings';
  String get routineManagement => isFrench ? 'Gestion des routines matin, après-midi et soir' : 'Morning, afternoon, and evening routine management';

  // User management
  String get addNewCrewMember => isFrench ? 'Ajouter un nouveau membre d\'équipage' : 'Add New Crew Member';
  String get recruitNewAstronaut => isFrench ? 'Recruter un nouvel astronaute dans votre équipe' : 'Recruit a new astronaut to your team';
  
  // Time Settings
  String get morningPeriod => isFrench ? 'Période matinale' : 'Morning Period';
  String get eveningPeriod => isFrench ? 'Période du soir' : 'Evening Period';
  String get startTime => isFrench ? 'Heure de début' : 'Start Time';
  String get endTime => isFrench ? 'Heure de fin' : 'End Time';
  String get timeSettingsSaved => isFrench ? 'Paramètres de temps sauvegardés!' : 'Time settings saved!';
  String get invalidTimeRange => isFrench ? 'Plage horaire invalide!' : 'Invalid time range!';
  
  // Progress & Stats
  String get progress => isFrench ? 'Progrès' : 'Progress';
  String get todayProgress => isFrench ? 'Progrès d\'aujourd\'hui' : 'Today\'s Progress';
  String get weeklyProgress => isFrench ? 'Progrès hebdomadaire' : 'Weekly Progress';
  String get streak => isFrench ? 'Série' : 'Streak';
  String get currentStreak => isFrench ? 'Série actuelle' : 'Current Streak';
  String get longestStreak => isFrench ? 'Plus longue série' : 'Longest Streak';
  String get level => isFrench ? 'Niveau' : 'Level';
  String get completionRate => isFrench ? 'Taux de réussite' : 'Completion Rate';
  
  String getStreakDays(int days) => 
    isFrench ? '$days jour${days > 1 ? 's' : ''}' : '$days day${days != 1 ? 's' : ''}';
  
  String getTasksCompleted(int completed, int total) =>
    isFrench ? '$completed/$total tâches terminées' : '$completed/$total tasks completed';
  
  // Additional UI text
  String get minutes => isFrench ? 'minutes' : 'minutes';
  String getMinutes(int count) => 
    isFrench ? '$count minute${count > 1 ? 's' : ''}' : '$count minute${count != 1 ? 's' : ''}';
  
  String get estimatedDuration => isFrench ? 'Durée estimée' : 'Estimated Duration';
  String get chooseIcon => isFrench ? 'Choisir une icône' : 'Choose Icon';
  String get customImage => isFrench ? 'Image personnalisée' : 'Custom Image';
  String get addImage => isFrench ? 'Ajouter une image' : 'Add Image';
  String get tapToChoose => isFrench ? 'Toucher pour choisir' : 'Tap to choose';
  String get chooseImage => isFrench ? 'Choisir une image' : 'Choose Image';
  String get gallery => isFrench ? 'Galerie' : 'Gallery';
  String get camera => isFrench ? 'Appareil photo' : 'Camera';  
  String get removeImage => isFrench ? 'Supprimer l\'image' : 'Remove Image';
  String get removeCustomImage => isFrench ? 'Retirer l\'image personnalisée' : 'Remove custom image';
  String get chooseFromGalleryDescription => isFrench ? 'Choisir depuis la galerie' : 'Choose from gallery';
  String get takePhotoDescription => isFrench ? 'Prendre une photo' : 'Take a photo';
  String get tapToComplete => isFrench ? 'Toucher pour terminer' : 'Tap to complete';
  String get completed => isFrench ? 'Terminé' : 'Completed';
  String get today => isFrench ? 'Aujourd\'hui' : 'Today';
  String get thisWeek => isFrench ? 'Cette semaine' : 'This week';
  String get totalCompleted => isFrench ? 'Total terminé' : 'Total completed';
  
  // Time period labels
  String getTimePeriodLabel(String period) {
    if (!isFrench) return period;
    switch (period.toLowerCase()) {
      case 'current':
        return 'Actuel';
      case 'morning':
        return 'Matin';
      case 'afternoon':
        return 'Après-midi';
      case 'evening':
        return 'Soir';
      default:
        return period;
    }
  }
  
  // Achievement display texts
  String get achievements => isFrench ? 'Réussites' : 'Achievements';
  String get noAchievements => isFrench ? 'Aucune réussite pour le moment' : 'No achievements yet';
  String getAchievementCount(int count) =>
    isFrench ? '$count réussite${count > 1 ? 's' : ''}' : '$count achievement${count != 1 ? 's' : ''}';
  
  // Profile and user info
  String get totalTasks => isFrench ? 'Tâches totales' : 'Total Tasks';
  String get bestStreak => isFrench ? 'Meilleure série' : 'Best Streak';
  String get favoriteCategory => isFrench ? 'Catégorie favorite' : 'Favorite Category';
  
  // Task time display
  String getTaskTime(int minutes) {
    if (minutes < 60) {
      return isFrench 
          ? '$minutes min' 
          : '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return isFrench 
            ? '$hours h' 
            : '${hours}h';
      } else {
        return isFrench 
            ? '$hours h $remainingMinutes min' 
            : '${hours}h ${remainingMinutes}m';
      }
    }
  }
  
  // Navigation and interface
  String get dashboard => isFrench ? 'Tableau de bord' : 'Dashboard';
  String get overview => isFrench ? 'Aperçu' : 'Overview';
  String get details => isFrench ? 'Détails' : 'Details';
  String get statistics => isFrench ? 'Statistiques' : 'Statistics';
  
  // Time-related
  String get timeOfDay => isFrench ? 'Moment de la journée' : 'Time of Day';
  String get schedule => isFrench ? 'Horaire' : 'Schedule';
  String get routine => isFrench ? 'Routine' : 'Routine';
  
  // Actions and buttons
  String get assign => isFrench ? 'Assigner' : 'Assign';
  String get unassign => isFrench ? 'Désassigner' : 'Unassign';
  String get complete => isFrench ? 'Terminer' : 'Complete';
  String get undo => isFrench ? 'Annuler' : 'Undo';
  String get reset => isFrench ? 'Réinitialiser' : 'Reset';
  String get refresh => isFrench ? 'Actualiser' : 'Refresh';
  
  // Status messages
  String get loading => isFrench ? 'Chargement...' : 'Loading...';
  String get noData => isFrench ? 'Aucune donnée' : 'No data';
  String get somethingWentWrong => isFrench ? 'Quelque chose s\'est mal passé' : 'Something went wrong';
  String get tryAgain => isFrench ? 'Réessayer' : 'Try again';
  
  // Day Selection
  String get selectDays => isFrench ? 'Sélectionner les jours' : 'Select Days';
  String get weekdays => isFrench ? 'Jours de semaine' : 'Weekdays';
  String get weekend => isFrench ? 'Week-end' : 'Weekend';
  String get allDays => isFrench ? 'Tous les jours' : 'All Days';
  String get assignToWhich => isFrench ? 'Assigner pour quels jours?' : 'Assign for which days?';
  
  // Confirmations
  String get areYouSure => isFrench ? 'Êtes-vous sûr?' : 'Are you sure?';
  String getUserDeleteConfirmation(String userName) =>
    isFrench ? 'Supprimer définitivement $userName? Cette action ne peut pas être annulée.' :
              'Permanently delete $userName? This action cannot be undone.';
  String getTaskDeleteConfirmation(String taskTitle) =>
    isFrench ? 'Supprimer définitivement "$taskTitle"? Cette action ne peut pas être annulée.' :
              'Permanently delete "$taskTitle"? This action cannot be undone.';
  String get resetProgressConfirmation =>
    isFrench ? 'Réinitialiser tous les progrès des utilisateurs? Cette action ne peut pas être annulée.' :
              'Reset all user progress? This action cannot be undone.';
  
  // Success Messages
  String get userCreated => isFrench ? 'Utilisateur créé avec succès!' : 'User created successfully!';
  String get userUpdated => isFrench ? 'Utilisateur mis à jour avec succès!' : 'User updated successfully!';
  String get userDeleted => isFrench ? 'Utilisateur supprimé avec succès!' : 'User deleted successfully!';
  String get taskCreated => isFrench ? 'Tâche créée avec succès!' : 'Task created successfully!';
  String get taskUpdated => isFrench ? 'Tâche mise à jour avec succès!' : 'Task updated successfully!';
  String get taskDeleted => isFrench ? 'Tâche supprimée avec succès!' : 'Task deleted successfully!';
  String get progressReset => isFrench ? 'Progrès réinitialisé avec succès!' : 'Progress reset successfully!';
  String getTaskAssigned(String taskTitle, String userName) =>
    isFrench ? '"$taskTitle" assignée à $userName!' : '"$taskTitle" assigned to $userName!';
  
  // Errors
  String get error => isFrench ? 'Erreur' : 'Error';
  String get fieldRequired => isFrench ? 'Ce champ est requis' : 'This field is required';
  String get pleaseEnterName => isFrench ? 'Veuillez entrer un nom' : 'Please enter a name';
  String get pleaseEnterTitle => isFrench ? 'Veuillez entrer un titre' : 'Please enter a title';
  String get selectAtLeastOneDay => isFrench ? 'Sélectionnez au moins un jour' : 'Select at least one day';
  
  // Empty States
  String get getStarted => isFrench ? 'Commencer' : 'Get Started';
  String get createFirstUser => isFrench ? 'Créer votre premier utilisateur' : 'Create your first user';
  String get addUsersToStart => isFrench ? 'Ajoutez des utilisateurs pour commencer à gérer les tâches' : 'Add users to start managing tasks';
  String get createFirstTask => isFrench ? 'Créer votre première tâche' : 'Create your first task';
  String get addTasksToAssign => isFrench ? 'Ajoutez des tâches pour pouvoir les assigner aux utilisateurs' : 'Add tasks to be able to assign them to users';
  String get noTasksForToday => isFrench ? 'Aucune tâche pour aujourd\'hui' : 'No tasks for today';
  String get allTasksCompleted => isFrench ? 'Toutes les tâches sont terminées!' : 'All tasks completed!';
  String get greatJobToday => isFrench ? 'Excellent travail aujourd\'hui!' : 'Great job today!';
  
  // Task Management Screen
  String getAssignedTasksForUser(String userName) =>
    isFrench ? 'Tâches assignées à $userName' : 'Tasks assigned to $userName';
  String get manageUserTasks => isFrench ? 'Gérer les tâches de l\'utilisateur' : 'Manage User Tasks';
  String get unassignTask => isFrench ? 'Désassigner la tâche' : 'Unassign Task';
  String get assignNewTask => isFrench ? 'Assigner une nouvelle tâche' : 'Assign New Task';
  
  // Quick Actions
  String get quickActions => isFrench ? 'Actions rapides' : 'Quick Actions';
  String get selectAll => isFrench ? 'Sélectionner tout' : 'Select All';
  String get clearAll => isFrench ? 'Tout effacer' : 'Clear All';
  
  // Mission Management
  String get missionOrders => isFrench ? 'Ordres de Mission' : 'Mission Orders';
  String get systemStatistics => isFrench ? 'Statistiques du système' : 'System Statistics';
  String get availableTasksForAssignment => isFrench ? 'Tâches disponibles pour assignation' : 'Available tasks for assignment';
  String get testActions => isFrench ? 'Actions de test' : 'Test Actions';
  String get createTestTask => isFrench ? 'Créer tâche test' : 'Create test task';
  String get assignRandomly => isFrench ? 'Assigner aléatoirement' : 'Assign randomly';
  String get unassignAll => isFrench ? 'Désassigner toutes' : 'Unassign all';
  String get totalTasksCount => isFrench ? 'Total des tâches' : 'Total tasks';
  String get unassignedTasks => isFrench ? 'Tâches non assignées' : 'Unassigned tasks';
  String get assignedTasks => isFrench ? 'Tâches assignées' : 'Assigned tasks';
  String getTasksForUser(String userName) => isFrench ? 'Tâches de $userName' : 'Tasks for $userName';
  String get days => isFrench ? 'Jours' : 'Days';
  
  // Family and Team
  String get familyMembers => isFrench ? 'Membres de la famille' : 'Family Members';
  String get teamMembers => isFrench ? 'Membres de l\'équipe' : 'Team Members';
  String get crewMembers => isFrench ? 'Membres d\'équipage' : 'Crew Members';
  String get readyToLaunch => isFrench ? 'Prêt au décollage!' : 'Ready to Launch!';
  String get addFamilyMembersToStart => isFrench ? 'Ajoutez des membres de la famille et créez des tâches\\npour commencer votre voyage spatial' : 'Add family members and create tasks\\nto get started on your space journey';
  String get noTasksToday => isFrench ? 'Pas de tâches aujourd\'hui! 🎉' : 'No tasks today! 🎉';
  String get dropTaskHere => isFrench ? 'Déposez la tâche ici pour l\'assigner!' : 'Drop task here to assign!';
  String get dragTasksFromBelow => isFrench ? 'Glissez des tâches depuis le bas pour les assigner' : 'Drag tasks from below to assign them';
  String get addTasksForUser => isFrench ? 'Ajoutez des tâches pour commencer' : 'Add tasks to get started';
  String get assigned => isFrench ? 'Assignée' : 'Assigned';
  
  // Task Translation Methods
  String getCategoryName(String englishCategory) {
    if (!isFrench) return englishCategory;
    switch (englishCategory) {
      case 'Personal Care': return 'Soins personnels';
      case 'School & Study': return 'École & Études';
      case 'Chores': return 'Corvées';
      case 'Health & Fitness': return 'Santé & Forme';
      case 'Creative': return 'Créatif';
      case 'General': return 'Général';
      default: return englishCategory;
    }
  }
  
  // Get localized task categories
  List<Map<String, dynamic>> get taskCategories {
    return [
      {
        'name': getCategoryName('Personal Care'),
        'englishName': 'Personal Care',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF4FC3F7),
      },
      {
        'name': getCategoryName('School & Study'),
        'englishName': 'School & Study',
        'icon': Icons.school,
        'color': const Color(0xFF66BB6A),
      },
      {
        'name': getCategoryName('Chores'),
        'englishName': 'Chores',
        'icon': Icons.cleaning_services,
        'color': const Color(0xFFFFB74D),
      },
      {
        'name': getCategoryName('Health & Fitness'),
        'englishName': 'Health & Fitness',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFFF8A65),
      },
      {
        'name': getCategoryName('Creative'),
        'englishName': 'Creative',
        'icon': Icons.palette,
        'color': const Color(0xFFBA68C8),
      },
      {
        'name': getCategoryName('General'),
        'englishName': 'General',
        'icon': Icons.task_alt,
        'color': const Color(0xFF90A4AE),
      },
    ];
  }
  
  // Sample Task Translations
  String getTaskTitle(String englishTitle) {
    if (!isFrench) return englishTitle;
    switch (englishTitle) {
      // Personal Care
      case 'Brush Teeth': return 'Se brosser les dents';
      case 'Take a Shower': return 'Prendre une douche';
      case 'Wash Face': return 'Se laver le visage';
      case 'Comb Hair': return 'Se coiffer';
      case 'Get Dressed': return 'S\'habiller';
      case 'Brush Teeth (Evening)': return 'Se brosser les dents (Soir)';
      
      // Chores
      case 'Make Bed': return 'Faire son lit';
      case 'Feed Pet': return 'Nourrir l\'animal';
      case 'Set Dining Table': return 'Mettre la table';
      case 'Water Plants': return 'Arroser les plantes';
      case 'Take Out Trash': return 'Sortir les poubelles';
      case 'Organize Toys': return 'Ranger les jouets';
      case 'Load Dishwasher': return 'Charger le lave-vaisselle';
      case 'Tidy Room': return 'Ranger sa chambre';
      case 'Help Cook Breakfast': return 'Aider à préparer le petit-déjeuner';
      
      // Health & Fitness
      case 'Morning Exercise': return 'Exercice matinal';
      case 'Drink Water': return 'Boire de l\'eau';
      case 'Take Vitamins': return 'Prendre des vitamines';
      case 'Go for a Walk': return 'Faire une promenade';
      case 'Outdoor Play': return 'Jouer dehors';
      
      // School & Study
      case 'Complete Homework': return 'Faire ses devoirs';
      case 'Pack School Bag': return 'Préparer son cartable';
      case 'Practice Music': return 'Pratiquer la musique';
      case 'Study for Test': return 'Réviser pour un contrôle';
      
      // Creative
      case 'Read Book': return 'Lire un livre';
      case 'Draw or Paint': return 'Dessiner ou peindre';
      case 'Write in Journal': return 'Écrire dans son journal';
      case 'Build with Blocks': return 'Construire avec des blocs';
      
      // General
      case 'Prepare Tomorrow\'s Clothes': return 'Préparer les vêtements de demain';
      case 'Review Day': return 'Réfléchir à sa journée';
      case 'Family Game Time': return 'Temps de jeu en famille';
      
      default: return englishTitle;
    }
  }
  
  String getTaskDescription(String englishDescription) {
    if (!isFrench) return englishDescription;
    
    switch (englishDescription) {
      case 'Daily dental hygiene - morning routine':
        return 'Hygiène dentaire quotidienne - routine matinale';
      case 'Daily hygiene and freshness':
        return 'Hygiène quotidienne et fraîcheur';
      case 'Fresh start to the day':
        return 'Commencer la journée en beauté';
      case 'Look neat and tidy':
        return 'Avoir l\'air soigné et propre';
      case 'Put on clean clothes':
        return 'Mettre des vêtements propres';
      case 'Tidy up bedroom every morning':
        return 'Ranger la chambre chaque matin';
      case 'Take care of family pets':
        return 'S\'occuper des animaux de la famille';
      case 'Prepare table for meals':
        return 'Préparer la table pour les repas';
      case 'Take care of household plants':
        return 'S\'occuper des plantes de la maison';
      case 'Empty bins and take to collection':
        return 'Vider les poubelles et les sortir';
      case 'Put away toys and games':
        return 'Ranger les jouets et jeux';
      case 'Help with kitchen cleanup':
        return 'Aider au nettoyage de la cuisine';
      case '15 minutes of stretching or physical activity':
        return '15 minutes d\'étirements ou d\'activité physique';
      case 'Stay hydrated throughout the day':
        return 'Rester hydraté tout au long de la journée';
      case 'Daily health supplements':
        return 'Suppléments de santé quotidiens';
      case 'Fresh air and light exercise':
        return 'Air frais et exercice léger';
      case 'Daily school assignments':
        return 'Devoirs scolaires quotidiens';
      case 'Prepare backpack for next day':
        return 'Préparer le sac à dos pour le lendemain';
      case 'Daily instrument practice':
        return 'Pratique quotidienne de l\'instrument';
      case 'Review materials and notes':
        return 'Réviser les matières et les notes';
      case 'Reading time for learning and relaxation':
        return 'Temps de lecture pour apprendre et se détendre';
      case 'Express creativity through art':
        return 'Exprimer sa créativité par l\'art';
      case 'Reflect on the day':
        return 'Réfléchir sur la journée';
      case 'Creative construction play':
        return 'Jeu de construction créatif';
      case 'Get ready for next day':
        return 'Se préparer pour le lendemain';
      case 'Night-time dental hygiene':
        return 'Hygiène dentaire du soir';
      case 'Organize personal space before bed':
        return 'Organiser son espace personnel avant le coucher';
      case 'Think about good things that happened':
        return 'Penser aux bonnes choses qui se sont passées';
      case 'Assist with weekend morning meal':
        return 'Aider avec le repas du matin du week-end';
      case 'Quality time with family':
        return 'Temps de qualité en famille';
      case 'Fresh air and physical activity':
        return 'Air frais et activité physique';
      
      // Nouvelles descriptions pour les tâches d'exemple  
      case 'Start the day with fresh breath and healthy teeth':
        return 'Commencer la journée avec une haleine fraîche et des dents saines';
      case 'Tidy up bedroom and start the day organized':
        return 'Ranger la chambre et commencer la journée organisé';
      case 'Finish daily school assignments and review lessons':
        return 'Terminer les devoirs quotidiens et réviser les leçons';
      case 'Enjoy a good story and expand imagination':
        return 'Profiter d\'une bonne histoire et développer l\'imagination';
      case 'Organize personal space for a peaceful night':
        return 'Organiser son espace personnel pour une nuit paisible';
      
      default:
        return englishDescription;
    }
  }
  
  // Parental Control
  String get parentalControl => isFrench ? 'Contrôle Parental' : 'Parental Control';
  String get solveMathProblem => isFrench ? 'Résolvez ce calcul pour accéder aux paramètres' : 'Solve this math problem to access settings';
  String get incorrectAnswer => isFrench ? 'Réponse incorrecte, réessayez' : 'Incorrect answer, try again';
  String get newProblemGenerated => isFrench ? 'Nouveau calcul généré' : 'New problem generated';
  String get accessGranted => isFrench ? 'Accès Autorisé !' : 'Access Granted!';
  String get redirectingToSettings => isFrench ? 'Redirection vers les paramètres...' : 'Redirecting to settings...';
  String get verify => isFrench ? 'Vérifier' : 'Verify';

  // Achievement translations
  String getAchievementTitle(String englishTitle) {
    if (!isFrench) return englishTitle;

    switch (englishTitle) {
      case 'First Steps':
        return 'Premiers Pas';
      case 'Week Warrior':
        return 'Guerrier de la Semaine';
      case 'Streak Master':
        return 'Maître des Séries';
      case 'Century Club':
        return 'Club des Cent';
      case 'Early Bird':
        return 'Lève-Tôt';
      default:
        return englishTitle;
    }
  }
  
  String getAchievementDescription(String englishDescription) {
    if (!isFrench) return englishDescription;

    switch (englishDescription) {
      case 'Complete your first task':
        return 'Termine ta première tâche';
      case 'Complete all tasks for an entire week':
        return 'Termine toutes les tâches pendant une semaine entière';
      case 'Maintain a 7-day completion streak':
        return 'Maintiens une série de 7 jours consécutifs';
      case 'Complete 100 tasks total':
        return 'Termine 100 tâches au total';
      case 'Complete morning routine tasks':
        return 'Termine les tâches de routine matinale';
      default:
        return englishDescription;
    }
  }
}