import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightGreen,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme),
      fontFamily: GoogleFonts.quicksand().fontFamily,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightGreen,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme),
      fontFamily: GoogleFonts.quicksand().fontFamily,
    );
  }
}
