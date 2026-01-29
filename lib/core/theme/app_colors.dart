import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color backgroundLight = Color(0xFF1A1F3A);
  static const Color cardBackground = Color(0xFF1E2337);
  static const Color surfaceColor = Color(0xFF252B44);
  static const Color bottomNavBackground = Color(0xFF0A0E27);
  static const Color dividerColor = Color(0xFF252B44);
  
  // Primary Colors
  static const Color primaryGreen = Color(0xFF00FF87);
  static const Color primaryGreenDark = Color(0xFF00CC6F);
  static const Color accentBlue = Color(0xFF3A7BD5);
  
  // Status Colors
  static const Color successGreen = Color(0xFF00FF87);
  static const Color errorRed = Color(0xFFFF3B5C);
  static const Color warningOrange = Color(0xFFFFB020);
  static const Color infoBlue = Color(0xFF3A7BD5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8CC);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Chart Colors
  static const Color chartLineBlue = Color(0xFF3A7BD5);
  static const Color chartLinePurple = Color(0xFF8B5CF6);
  static const Color chartGreen = Color(0xFF00FF87);
  static const Color chartRed = Color(0xFFFF3B5C);
  static const Color chartVolume = Color(0xFF374151);
  
  // Sector Colors for Portfolio Donut Chart
  static const Color sectorBanking = Color(0xFF3B82F6);
  static const Color sectorHydropower = Color(0xFF10B981);
  static const Color sectorInsurance = Color(0xFFF59E0B);
  static const Color sectorManufacturing = Color(0xFF8B5CF6);
  static const Color sectorHotels = Color(0xFFEC4899);
  static const Color sectorFinance = Color(0xFF06B6D4);
  
  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF00CC6F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient redGradient = LinearGradient(
    colors: [errorRed, Color(0xFFCC2F47)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2337), Color(0xFF252B44)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Opacity Colors
  static Color greenWithOpacity(double opacity) => 
      primaryGreen.withOpacity(opacity);
  
  static Color redWithOpacity(double opacity) => 
      errorRed.withOpacity(opacity);
}
