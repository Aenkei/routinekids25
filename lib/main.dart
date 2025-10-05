

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/screens/home_screen.dart';
import 'package:dreamflow/screens/language_selection_screen.dart';
import 'package:dreamflow/services/data_manager.dart';
import 'package:dreamflow/services/localization_service.dart';
import 'package:dreamflow/services/premium_manager.dart';
import 'theme.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PremiumManager>(
          create: (_) => PremiumManager(prefs),
        ),
        ChangeNotifierProvider<DataManager>(
          create: (_) {
            final dataManager = DataManager(prefs);
            dataManager.loadData();
            return dataManager;
          },
        ),
        ChangeNotifierProvider<LocalizationService>(
          create: (_) => LocalizationService(),
        ),
      ],
      child: Consumer3<DataManager, LocalizationService, PremiumManager>(
        builder: (context, dataManager, localizationService, premiumManager, child) {
          // Set the localization service and premium manager in data manager
          dataManager.setLocalizationService(localizationService);
          dataManager.setPremiumManager(premiumManager);
          
          // Check if this is first app launch
          final bool isFirstLaunch = !(prefs.getBool('language_selected') ?? false);
          
          return MaterialApp(
            title: 'RoutineKids',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            home: isFirstLaunch ? const LanguageSelectionScreen() : const HomeScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/language': (context) => const LanguageSelectionScreen(),
            },
          );
        },
      ),
    );
  }
}