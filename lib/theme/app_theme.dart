import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Palette ────────────────────────────────────────────────────
  static const _primaryLight = Color(0xFF9E7E38); // Deeper Gold for Light Mode
  static const _primaryDark  = Color(0xFFD4AF37);

  static const _bgLight           = Color(0xFFFDFBF7);
  static const _surfaceLight      = Color(0xFFFFFFFF);
  static const _surfaceHiLight    = Color(0xFFF2EEE7); // Darker HiLight for better separation

  static const _bgDark            = Color(0xFF050505);
  static const _surfaceDark       = Color(0xDA121212); // Semi-transparent for glass effect
  static const _surfaceHiDark     = Color(0xDA1E1E1E);

  // ─── Text Theme ─────────────────────────────────────────────────
  static TextTheme _textTheme(Color base) {
    final sansTheme = GoogleFonts.plusJakartaSansTextTheme();
    final serifTheme = GoogleFonts.crimsonProTextTheme();
    
    return sansTheme.copyWith(
      displayLarge:   serifTheme.displayLarge?.copyWith(color: base, fontWeight: FontWeight.w800, letterSpacing: -1.5),
      displayMedium:  serifTheme.displayMedium?.copyWith(color: base, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall:   serifTheme.displaySmall?.copyWith(color: base, fontWeight: FontWeight.w600),
      headlineLarge:  sansTheme.headlineLarge?.copyWith(color: base, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: sansTheme.headlineMedium?.copyWith(color: base, fontWeight: FontWeight.w700),
      headlineSmall:  sansTheme.headlineSmall?.copyWith(color: base, fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge:     sansTheme.titleLarge?.copyWith(color: base, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium:    sansTheme.titleMedium?.copyWith(color: base, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall:     sansTheme.titleSmall?.copyWith(color: base, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge:      sansTheme.bodyLarge?.copyWith(color: base, fontSize: 16, height: 1.5),
      bodyMedium:     sansTheme.bodyMedium?.copyWith(color: base, fontSize: 14, height: 1.4),
      bodySmall:      sansTheme.bodySmall?.copyWith(color: base.withAlpha(153), fontSize: 12),
      labelLarge:     sansTheme.labelLarge?.copyWith(color: base, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  // ─── Input Decoration ─────────────────────────────────────────
  static InputDecorationTheme _inputTheme(Color fill, Color focused, Color label) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: focused, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: label),
        hintStyle: GoogleFonts.plusJakartaSans(color: label),
      );

  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary:           _primaryLight,
      onPrimary:         Colors.white,
      secondary:         Color(0xFF8B6E30), // Deeper secondary for light mode
      onSecondary:       Colors.white,
      error:             Color(0xFFE11D48),
      onError:           Colors.white,
      surface:           _surfaceLight,
      onSurface:         Color(0xFF1A1A1A),
      surfaceContainerHighest: _surfaceHiLight,
      onSurfaceVariant:  Color(0xFF4A453C), // Much darker for legibility
      outline:           Color(0xFFD1CEC4), // More prominent outline
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgLight,
      textTheme: _textTheme(const Color(0xFF1A1A1A)),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgLight,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A1A1A), fontSize: 22, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 4, // Added elevation for light mode
        shadowColor: Colors.black.withAlpha(20),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: _inputTheme(_surfaceHiLight, _primaryLight, const Color(0xFF706B5E)),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceHiLight,
        selectedColor: _primaryLight,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
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
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primaryLight.withAlpha(30),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primaryLight),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary:           _primaryDark,
      onPrimary:         Color(0xFF050505),
      secondary:         Color(0xFFC5A059),
      onSecondary:       Color(0xFF050505),
      error:             Color(0xFFE11D48),
      onError:           Colors.black,
      surface:           _surfaceDark,
      onSurface:         Color(0xFFFDFBF7),
      surfaceContainerHighest: _surfaceHiDark,
      onSurfaceVariant:  Color(0xFFA6A29A),
      outline:           Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgDark,
      textTheme: _textTheme(const Color(0xFFFDFBF7)),
      appBarTheme: AppBarTheme(
        backgroundColor: _bgDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFFFDFBF7), fontSize: 22, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Color(0xFFFDFBF7)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: _inputTheme(_surfaceHiDark, _primaryDark, const Color(0xFFA6A29A)),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceHiDark,
        selectedColor: _primaryDark,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: const Color(0xFF050505),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryDark.withAlpha(38),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primaryDark),
    );
  }
}
