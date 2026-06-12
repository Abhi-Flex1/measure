enum UnitSystem { imperial, metric }

class UnitConverter {
  static const double metersToFeet = 3.28084;
  static const double metersToInches = 39.3701;
  static const double feetToMeters = 0.3048;
  static const double inchesToMeters = 0.0254;

  static String formatDistance(double meters, {UnitSystem unit = UnitSystem.imperial}) {
    if (unit == UnitSystem.imperial) {
      return _formatImperial(meters);
    } else {
      return _formatMetric(meters);
    }
  }

  static String _formatImperial(double meters) {
    final totalInches = meters * metersToInches;
    
    if (totalInches < 12) {
      final inches = totalInches.round();
      return '$inches"';
    }
    
    final feet = (totalInches / 12).floor();
    final remainingInches = (totalInches % 12).round();
    
    if (remainingInches == 0) {
      return "$feet'";
    }
    
    return "$feet' $remainingInches\"";
  }

  static String _formatMetric(double meters) {
    if (meters < 1) {
      final cm = (meters * 100).toStringAsFixed(1);
      return '$cm cm';
    }
    
    return '${meters.toStringAsFixed(2)} m';
  }

  static String formatDistanceWithUnit(double meters, {UnitSystem unit = UnitSystem.imperial}) {
    final formatted = formatDistance(meters, unit: unit);
    return formatted;
  }
}
