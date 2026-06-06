import 'package:flutter/material.dart';

/// ONYX Design System — Color Palette
///
/// Dark theme only. Hierarchy comes from typography and spacing,
/// not from color overuse. Accent used sparingly.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceSecondary = Color(0xFF171717);

  // ── Borders & Dividers ───────────────────────────────────────
  static const Color border = Color(0xFF262626);
  static const Color borderSubtle = Color(0xFF1C1C1C);
  static const Color borderHover = Color(0xFF333333);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textTertiary = Color(0xFF737373);
  static const Color textDisabled = Color(0xFF525252);

  // ── Status ───────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0xFF14532D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0xFF78350F);
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0xFF7F1D1D);

  // ── Accent ───────────────────────────────────────────────────
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentMuted = Color(0xFF1E3A5F);
  static const Color accentSubtle = Color(0xFF172554);

  // ── Facility-specific (subtle differentiation) ───────────────
  static const Color badminton = Color(0xFF3B82F6);
  static const Color cricketTurf = Color(0xFF22C55E);
  static const Color cricketNets = Color(0xFFF59E0B);

  // ── Interactive ──────────────────────────────────────────────
  static const Color hoverOverlay = Color(0x0DFFFFFF); // 5% white
  static const Color pressedOverlay = Color(0x1AFFFFFF); // 10% white
  static const Color selectedRow = Color(0xFF141414);
}
