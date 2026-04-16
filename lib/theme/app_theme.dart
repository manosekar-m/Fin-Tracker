import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Palette ────────────────────────────────────────────────────
  static const _primaryLight = Color(0xFF00897B);
  static const _primaryDark  = Color(0xFF26D0C4);

  static const _bgLight           = Color(0xFFF0F4F8);
  static const _surfaceLight      = Color(0xFFFFFFFF);
  static const _surfaceHiLight    = Color(0xFFE8EDF2);

  static const _bgDark            = Color(0xFF0A0F1E);
  static const _surfaceDark       = Color(0xFF131C2F);
  static const _surfaceHiDark     = Color(0xFF1C2840);

  // ─── Text Theme ─────────────────────────────────────────────────
  static TextTheme _textTheme(Color base) => GoogleFonts.outfitTextTheme(TextTheme(
        displayLarge:   TextStyle(color: base, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium:  TextStyle(color: base, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall:   TextStyle(color: base, fontWeight: FontWeight.w600),
        headlineLarge:  TextStyle(color: base, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: base, fontWeight: FontWeight.w700),
        headlineSmall:  TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge:     TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium:    TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:     TextStyle(color: base, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge:      TextStyle(color: base, fontSize: 16),
        bodyMedium:     TextStyle(color: base, fontSize: 14),
        bodySmall:      TextStyle(color: base.withAlpha(153), fontSize: 12),
        labelLarge:     TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 14),
      ));

  // ─── Input Decoration ─────────────────────────────────────────
  static InputDecorationTheme _inputTheme(Color fill, Color focused, Color label) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: focused, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.outfit(color: label),
        hintStyle: GoogleFonts.outfit(color: label),
      );

  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary:           _primaryLight,
      onPrimary:         Colors.white,
      secondary:         Color(0xFF0097A7),
      onSecondary:       Colors.white,
      error:             Color(0xFFE53935),
      onError:           Colors.white,
      surface:           _surfaceLight,
      onSurface:         Color(0xFF0D1B2A),
      surfaceContainerHighest: _surfaceHiLight,
      onSurfaceVariant:  Color(0xFF607080),
      outline:           Color(0xFFCDD5DF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgLight,
      textTheme: _textTheme(const Color(0xFF0D1B2A)),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgLight,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.outfit(color: const Color(0xFF0D1B2A), fontSize: 22, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: _inputTheme(_surfaceHiLight, _primaryLight, const Color(0xFF607080)),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceHiLight,
        selectedColor: _primaryLight,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primaryLight.withAlpha(30),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primaryLight),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary:           _primaryDark,
      onPrimary:         Color(0xFF00201D),
      secondary:         Color(0xFF4DD0E1),
      onSecondary:       Color(0xFF002026),
      error:             Color(0xFFFF6B6B),
      onError:           Colors.black,
      surface:           _surfaceDark,
      onSurface:         Color(0xFFE8EDF2),
      surfaceContainerHighest: _surfaceHiDark,
      onSurfaceVariant:  Color(0xFF8A9BB0),
      outline:           Color(0xFF1E2D42),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgDark,
      textTheme: _textTheme(const Color(0xFFE8EDF2)),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.outfit(color: const Color(0xFFE8EDF2), fontSize: 22, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Color(0xFFE8EDF2)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: _inputTheme(_surfaceHiDark, _primaryDark, const Color(0xFF8A9BB0)),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceHiDark,
        selectedColor: _primaryDark,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: const Color(0xFF00201D),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryDark.withAlpha(38),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primaryDark),
    );
  }
}
