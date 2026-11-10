import 'package:flutter/material.dart';

// ─── Couleurs ─────────────────────────────────────────────────────────────
const Color kBackground = Color(0xFFE8EAF0);
const Color kShadowDark = Color(0xFFC5C8D4);
const Color kShadowLight = Color(0xFFFFFFFF);
const Color kAccent = Color(0xFF6C8EBF);
const Color kAccentLight = Color(0xFF8BAFD8);
const Color kTextPrimary = Color(0xFF3D4456);
const Color kTextSecond = Color(0xFF7A82A0);
const Color kDanger = Color(0xFFD97B7B);

// Variantes transparentes (const, remplacent withOpacity)
const Color kAccentSoft = Color(0x1A6C8EBF); // 10 %
const Color kDangerSoft = Color(0x1FD97B7B); // 12 %
const Color kDangerChip = Color(0x26D97B7B); // 15 %
const Color kAccentGlow = Color(0x666C8EBF); // 40 %
const Color kAccentFocus = Color(0x2E6C8EBF); // 18 %

// ─── Ombres ───────────────────────────────────────────────────────────────
const List<BoxShadow> neuShadowOut = [
  BoxShadow(color: kShadowDark, offset: Offset(6, 6), blurRadius: 12),
  BoxShadow(color: kShadowLight, offset: Offset(-6, -6), blurRadius: 12),
];
const List<BoxShadow> neuShadowIn = [
  BoxShadow(color: kShadowDark, offset: Offset(4, 4), blurRadius: 8),
  BoxShadow(color: kShadowLight, offset: Offset(-4, -4), blurRadius: 8),
];
const List<BoxShadow> neuShadowOutSmall = [
  BoxShadow(color: kShadowDark, offset: Offset(3, 3), blurRadius: 6),
  BoxShadow(color: kShadowLight, offset: Offset(-3, -3), blurRadius: 6),
];
const List<BoxShadow> neuShadowAccent = [
  BoxShadow(color: kAccentGlow, offset: Offset(4, 4), blurRadius: 10),
  BoxShadow(color: kShadowLight, offset: Offset(-3, -3), blurRadius: 8),
];
const List<BoxShadow> neuShadowFocus = [
  BoxShadow(color: kAccentFocus, offset: Offset(0, 4), blurRadius: 12),
  ...neuShadowIn,
];

// ─── Décorations ─────────────────────────────────────────────────────────
BoxDecoration neuBoxOut({double radius = 16}) => BoxDecoration(
      color: kBackground,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: neuShadowOut,
    );

BoxDecoration neuBoxIn({double radius = 12}) => BoxDecoration(
      color: kBackground,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: neuShadowIn,
    );

BoxDecoration neuBoxAccent({double radius = 16}) => BoxDecoration(
      color: kAccent,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: neuShadowAccent,
    );

BoxDecoration neuBoxOutSmall({double radius = 12}) => BoxDecoration(
      color: kBackground,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: neuShadowOutSmall,
    );

// ─── Theme ────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() => ThemeData(
      scaffoldBackgroundColor: kBackground,
      colorScheme: const ColorScheme.light(
        primary: kAccent,
        secondary: kAccentLight,
        surface: kBackground,
        error: kDanger,
      ),
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kTextPrimary),
        titleTextStyle: TextStyle(
          color: kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: kTextPrimary,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );