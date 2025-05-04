import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.black,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.grey[600],
  ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    bodyMedium: const TextStyle(fontSize: 16, color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
);
