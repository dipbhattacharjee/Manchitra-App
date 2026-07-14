import 'package:flutter/material.dart';

/// ============================================================
/// MANCHITRA — DURGA PUJA 2026 PANDAL HOP APP
/// Master Color Palette (Morning Puja Light Theme)
/// ============================================================

class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── PRIMARY: Deep Vermillion / Crimson ────────────────────────
  static const Color primary = Color(0xFFAF101A);
  static const Color primaryLight = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFF7A000A);
  static const Color primaryContainer = Color(0xFFFFDAD6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF410003);

  // ─── SECONDARY: Marigold Gold / Amber ──────────────────────────
  static const Color secondary = Color(0xFF785900);
  static const Color secondaryLight = Color(0xFFFDC003);
  static const Color secondaryDark = Color(0xFF5B4300);
  static const Color secondaryContainer = Color(0xFFFFDF9E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF261A00);

  // ─── TERTIARY: Sindoor / Rose Crimson ──────────────────────────
  static const Color tertiary = Color(0xFFA22456);
  static const Color tertiaryLight = Color(0xFFC23E6E);
  static const Color tertiaryDark = Color(0xFF8B0E45);
  static const Color tertiaryContainer = Color(0xFFFDD9E1);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF3F001B);

  // ─── BACKGROUNDS & SURFACES ────────────────────────────────────
  static const Color background = Color(0xFFFBF9F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFDBDAD6);
  static const Color surfaceBright = Color(0xFFFBF9F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EF);
  static const Color surfaceContainer = Color(0xFFEFEEEA);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E4);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DE);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ─── TEXT COLORS ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B1C1A);
  static const Color textSecondary = Color(0xFF5B403D);
  static const Color textMuted = Color(0xFF8F6F6C);
  static const Color textDisabled = Color(0xFFC4BEBA);

  // ─── BORDERS & DIVIDERS ──────────────────────────────────────
  static const Color border = Color(0xFFE4BEBA);
  static const Color borderAccent = Color(0xFF8F6F6C);
  static const Color divider = Color(0xFFE4E2DE);

  // ─── CROWD LEVEL INDICATORS ──────────────────────────────────
  static const Color crowdLow = Color(0xFF2A8A4A);      // Green
  static const Color crowdMedium = Color(0xFFC8961A);   // Gold
  static const Color crowdHigh = Color(0xFFE8531A);     // Saffron
  static const Color crowdVeryHigh = Color(0xFF8B1A4A); // Crimson

  // ─── TRANSPORT MODE COLORS ───────────────────────────────────
  static const Color transportWalk = Color(0xFF4A9A6A);   // Soft green
  static const Color transportMetro = Color(0xFF2A6AB0);  // Metro blue
  static const Color transportTrain = Color(0xFF8B5E2A);  // Train brown
  static const Color transportCab = Color(0xFFE8531A);    // Saffron cab
  static const Color transportAuto = Color(0xFFC8961A);   // Gold auto

  // ─── STATUS COLORS ───────────────────────────────────────────
  static const Color success = Color(0xFF2A8A4A);
  static const Color warning = Color(0xFFC8961A);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF2A6AB0);

  // ─── SPECIAL EFFECTS ─────────────────────────────────────────
  static const Color glowSaffron = Color(0x33AF101A);
  static const Color glowGold = Color(0x22FDC003);
  static const Color modalOverlay = Color(0x99000000);
  static const Color scrim = Color(0x66000000);

  // ─── GRADIENT PRESETS ────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, tertiary],
    stops: [0.0, 1.0],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, Color(0xFFC23E6E)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceContainerLow],
    stops: [0.0, 1.0],
  );

  static const RadialGradient splashGradient = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [Color(0xFFFFF2F0), background],
    stops: [0.0, 1.0],
  );

  static const LinearGradient featuredCardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x99000000)],
    stops: [0.3, 1.0],
  );
}

