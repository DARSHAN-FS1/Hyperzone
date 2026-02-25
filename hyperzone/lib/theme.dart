// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color neonBlue = Color(0xFF00C6FF);
  static const Color neonPurple = Color(0xFF7B61FF);
  static const Color neonPink = Color(0xFFFF4DAB);
  static const Color darkBg = Color(0xFF0B0F18);
  static const Color cardBg = Color(0xFF0F1724);
}

LinearGradient neonGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.neonBlue, AppColors.neonPurple, AppColors.neonPink],
);

BoxDecoration neonGradientDecoration = BoxDecoration(
  gradient: neonGradient,
  boxShadow: [
    BoxShadow(
      color: Color(0xFF7B61FF).withOpacity(0.15),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ],
);

TextStyle headingStyle = const TextStyle(
  color: Colors.white,
  fontSize: 28,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.4,
);
