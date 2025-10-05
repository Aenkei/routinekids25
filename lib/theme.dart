import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modern Space-Themed Netflix-Style Design System
class SpaceColors {
  // Space Primary Colors
  static const Color deepSpacePurple = Color(0xFF1a0033);
  static const Color spacePurple = Color(0xFF2d1b69);
  static const Color cosmicBlue = Color(0xFF0f3460);
  static const Color cosmicBlueDark = Color(0xFF16537e);
  
  // Accent Colors
  static const Color nebulaPink = Color(0xFFff6b9d);
  static const Color nebulaPinkDark = Color(0xFFc44569);
  static const Color starYellow = Color(0xFFffd700);
  static const Color galaxyGreen = Color(0xFF00ff88);
  
  // Background Colors
  static const Color spaceBlack = Color(0xFF0c0c0c);
  static const Color spaceBlackLight = Color(0xFF1a1a1a);
  static const Color darkMatter = Color(0xFF1e1e1e);
  static const Color darkMatterLight = Color(0xFF2a2a2a);
  
  // Text Colors
  static const Color starWhite = Color(0xFFffffff);
  static const Color starWhiteSecondary = Color(0xFFe0e0e0);
  static const Color starWhiteTertiary = Color(0xFFb0b0b0);
  
  // Gradients
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepSpacePurple, spacePurple, cosmicBlue],
  );
  
  static const LinearGradient nebulaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [nebulaPink, nebulaPinkDark],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkMatter, darkMatterLight],
  );
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: SpaceColors.spacePurple,
        secondary: SpaceColors.cosmicBlue,
        tertiary: SpaceColors.nebulaPink,
        surface: SpaceColors.darkMatter,
        background: SpaceColors.spaceBlack,
        error: const Color(0xFFFF5963),
        onPrimary: SpaceColors.starWhite,
        onSecondary: SpaceColors.starWhite,
        onTertiary: SpaceColors.starWhite,
        onSurface: SpaceColors.starWhite,
        onBackground: SpaceColors.starWhite,
        onError: SpaceColors.starWhite,
        outline: SpaceColors.starWhiteTertiary,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: SpaceColors.spaceBlack,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: SpaceColors.starWhite,
        ),
        iconTheme: const IconThemeData(
          color: SpaceColors.starWhite,
          size: 28,
        ),
      ),
      cardTheme: CardThemeData(
        color: SpaceColors.darkMatter,
        elevation: 8,
        shadowColor: SpaceColors.spacePurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SpaceColors.nebulaPink,
          foregroundColor: SpaceColors.starWhite,
          elevation: 8,
          shadowColor: SpaceColors.nebulaPink.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SpaceColors.starWhite,
          side: const BorderSide(color: SpaceColors.spacePurple, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: SpaceColors.starWhite,
        size: 24,
      ),
      textTheme: TextTheme(
        // Display styles - Netflix-like headers
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
          color: SpaceColors.starWhite,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
          color: SpaceColors.starWhite,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          color: SpaceColors.starWhite,
          letterSpacing: -0.5,
        ),
        
        // Headline styles
        headlineLarge: GoogleFonts.inter(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: SpaceColors.starWhite,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: SpaceColors.starWhite,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: SpaceColors.starWhite,
        ),
        
        // Title styles
        titleLarge: GoogleFonts.inter(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhite,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhite,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhite,
        ),
        
        // Label styles
        labelLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhite,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhiteSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: SpaceColors.starWhiteTertiary,
        ),
        
        // Body styles
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: SpaceColors.starWhite,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: SpaceColors.starWhiteSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: SpaceColors.starWhiteTertiary,
          height: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpaceColors.darkMatter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpaceColors.spacePurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SpaceColors.spacePurple.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpaceColors.nebulaPink, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: SpaceColors.starWhiteSecondary,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: SpaceColors.starWhiteTertiary,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SpaceColors.darkMatter,
        elevation: 16,
        shadowColor: SpaceColors.spacePurple.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: SpaceColors.starWhite,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: SpaceColors.starWhiteSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SpaceColors.darkMatter,
        modalBackgroundColor: SpaceColors.darkMatter,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );

ThemeData get darkTheme => lightTheme; // Use same theme for both modes

// Custom widget extensions for consistent theming
extension ThemeExtensions on BuildContext {
  // Quick access to space colors
  SpaceColors get spaceColors => SpaceColors();
  
  // Common gradient decorations
  BoxDecoration get spaceGradientDecoration => const BoxDecoration(
    gradient: SpaceColors.spaceGradient,
  );
  
  BoxDecoration get cardGradientDecoration => BoxDecoration(
    gradient: SpaceColors.cardGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: SpaceColors.spacePurple.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  BoxDecoration get nebulaGradientDecoration => BoxDecoration(
    gradient: SpaceColors.nebulaGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: SpaceColors.nebulaPink.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}