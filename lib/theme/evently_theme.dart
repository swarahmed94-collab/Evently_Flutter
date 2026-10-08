import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class EventlyColors {
  static const navy = Color(0xFF000F30);
  static const darkSurface = Color(0xFF001440);
  static const lightBackground = Color(0xFFF4F7FF);
  static const deepBlue = Color(0xFF0E3A99);
  static const accent = Color(0xFF457AED);
  static const borderBlue = Color(0xFF002D8F);
  static const muted = Color(0xFF888C98);
  static const lightOutline = Color(0xFFE2E7F3);
  static const darkSecondary = Color(0xFFD7DCE9);
  static const red = Color(0xFFFF3B4D);

  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color outline(BuildContext context) => isDark(context)
      ? borderBlue : lightOutline;
  static Color secondaryText(BuildContext context) => isDark(context)
      ? darkSecondary : const Color(0xFF686868);
}

abstract final class EventlyTheme {
  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);

  static ThemeData _build(bool dark) {
    final bg = dark ? EventlyColors.navy : EventlyColors.lightBackground;
    final surface = dark ? EventlyColors.darkSurface : Colors.white;
    final primary = dark ? EventlyColors.accent : EventlyColors.deepBlue;
    final fg = dark ? Colors.white : const Color(0xFF17171C);
    final outline = dark ? EventlyColors.borderBlue : EventlyColors.lightOutline;
    final material = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: fg,
        outline: outline,
        error: EventlyColors.red,
      ),
    );
    final typography = GoogleFonts.poppinsTextTheme(material.textTheme)
        .apply(bodyColor: fg, displayColor: fg);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: dark ? outline : Colors.transparent),
    );
    return material.copyWith(
      textTheme: typography,
      primaryTextTheme: typography,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarThemeData(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          color: fg, fontSize: 16, fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: outline, width: dark ? 1 : .5),
        ),
      ),
      iconTheme: IconThemeData(color: primary),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        isDense: true,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12, color: dark ? const Color(0xFF9BA9C9) : const Color(0xFF98999E),
        ),
        prefixIconColor: dark ? const Color(0xFFA7B7DD) : const Color(0xFFB8BAC1),
        suffixIconColor: dark ? const Color(0xFFA7B7DD) : const Color(0xFFB8BAC1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: primary, width: 1.4)),
        errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: EventlyColors.red)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: EventlyColors.red)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: .55),
          elevation: 0,
          shape: shape,
          minimumSize: const Size.fromHeight(46),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      )),
      dividerColor: outline,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? bg : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: dark ? const Color(0xFFACB7D4) : const Color(0xFFBABCC2),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: fg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF182C58) : const Color(0xFF1C2E56),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
