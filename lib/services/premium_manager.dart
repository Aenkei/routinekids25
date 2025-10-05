import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion du statut Premium
class PremiumManager extends ChangeNotifier {
  final SharedPreferences prefs;
  static const String _premiumKey = 'isPremium';
  
  // Limitations gratuites
  static const int maxFreeUsers = 1;
  static const int maxFreeTasks = 3;
  static const List<String> freeProgressStyles = ['rainbow'];
  static const List<String> premiumProgressStyles = ['neon', 'crystal', 'dynamic'];
  
  PremiumManager(this.prefs) {
    _loadPremiumStatus();
  }
  
  bool _isPremium = false;
  bool get isPremium => _isPremium;
  
  void _loadPremiumStatus() {
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }
  
  Future<void> _savePremiumStatus() async {
    await prefs.setBool(_premiumKey, _isPremium);
    notifyListeners();
  }
  
  /// Vérifie si l'utilisateur peut ajouter un nouvel utilisateur
  bool canAddUser(int currentUserCount) {
    if (_isPremium) return true;
    return currentUserCount < maxFreeUsers;
  }
  
  /// Vérifie si l'utilisateur peut ajouter une nouvelle tâche
  bool canAddTask(int currentTaskCount) {
    if (_isPremium) return true;
    return currentTaskCount < maxFreeTasks;
  }
  
  /// Vérifie si l'utilisateur peut utiliser un style de progression spécifique
  bool canUseProgressStyle(String style) {
    if (_isPremium) return true;
    return freeProgressStyles.contains(style);
  }
  
  /// Obtient la liste des styles disponibles selon le statut premium
  List<String> getAvailableProgressStyles() {
    if (_isPremium) {
      return [...freeProgressStyles, ...premiumProgressStyles];
    }
    return freeProgressStyles;
  }
  
  /// Active le statut premium (pour test/démonstration)
  Future<void> upgradeToPremiun() async {
    _isPremium = true;
    await _savePremiumStatus();
    notifyListeners();
  }
  
  /// Désactive le statut premium (pour test/démonstration)
  Future<void> downgradeToFree() async {
    _isPremium = false;
    await _savePremiumStatus();
    notifyListeners();
  }
  
  /// Bascule le statut premium (pour test)
  Future<void> togglePremiumStatus() async {
    _isPremium = !_isPremium;
    await _savePremiumStatus();
    notifyListeners();
  }
  
  /// Obtient les informations sur les limitations actuelles
  PremiumLimitationInfo getLimitationInfo(int userCount, int taskCount) {
    return PremiumLimitationInfo(
      isPremium: _isPremium,
      currentUsers: userCount,
      maxFreeUsers: maxFreeUsers,
      currentTasks: taskCount,
      maxFreeTasks: maxFreeTasks,
      canAddUser: canAddUser(userCount),
      canAddTask: canAddTask(taskCount),
    );
  }
  
  /// Obtient la liste des bénéfices premium
  List<PremiumBenefit> getPremiumBenefits() {
    return [
      PremiumBenefit(
        icon: '👥',
        title: 'Utilisateurs Illimités',
        description: 'Ajoutez tous les membres de votre famille',
        isUnlocked: _isPremium,
      ),
      PremiumBenefit(
        icon: '✅',
        title: 'Tâches Illimitées',
        description: 'Créez autant de tâches que nécessaire',
        isUnlocked: _isPremium,
      ),
      PremiumBenefit(
        icon: '🎨',
        title: 'Styles Exclusifs',
        description: 'Accès à tous les styles de progression',
        isUnlocked: _isPremium,
      ),
      PremiumBenefit(
        icon: '⭐',
        title: 'Expérience Premium',
        description: 'Interface sans limitations ni publicités',
        isUnlocked: _isPremium,
      ),
    ];
  }
}

/// Informations sur les limitations premium
class PremiumLimitationInfo {
  final bool isPremium;
  final int currentUsers;
  final int maxFreeUsers;
  final int currentTasks;
  final int maxFreeTasks;
  final bool canAddUser;
  final bool canAddTask;
  
  const PremiumLimitationInfo({
    required this.isPremium,
    required this.currentUsers,
    required this.maxFreeUsers,
    required this.currentTasks,
    required this.maxFreeTasks,
    required this.canAddUser,
    required this.canAddTask,
  });
  
  /// Obtient le nombre d'utilisateurs restants (gratuit)
  int get remainingFreeUsers => maxFreeUsers - currentUsers;
  
  /// Obtient le nombre de tâches restantes (gratuit)
  int get remainingFreeTasks => maxFreeTasks - currentTasks;
}

/// Représente un bénéfice premium
class PremiumBenefit {
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;
  
  const PremiumBenefit({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

/// Types de limitation premium
enum PremiumLimitationType {
  users,
  tasks,
  progressStyles,
}