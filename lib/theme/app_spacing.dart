import 'package:flutter/material.dart';

/// Centralized spacing constants
class AppSpacing {
  // Micro spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Common padding/margin values
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  // Border radius values
  static const double borderRadiusSM = 8.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;
  static const double borderRadiusXL = 24.0;

  // Common border radius
  static const BorderRadius radiusSM = BorderRadius.all(
    Radius.circular(borderRadiusSM),
  );
  static const BorderRadius radiusMD = BorderRadius.all(
    Radius.circular(borderRadiusMD),
  );
  static const BorderRadius radiusLG = BorderRadius.all(
    Radius.circular(borderRadiusLG),
  );
  static const BorderRadius radiusXL = BorderRadius.all(
    Radius.circular(borderRadiusXL),
  );

  // Elevation values
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
