import 'package:flutter/material.dart';
import '../models/measurement_session.dart';
import '../utils/unit_converter.dart';

class DistanceLabel extends StatelessWidget {
  final MeasurementSession session;
  final UnitSystem unit;

  const DistanceLabel({
    super.key,
    required this.session,
    this.unit = UnitSystem.imperial,
  });

  @override
  Widget build(BuildContext context) {
    if (session.mode == MeasurementMode.simple) {
      return _buildSimpleLabel();
    } else {
      return _buildMultiLabel();
    }
  }

  Widget _buildSimpleLabel() {
    final measurement = session.currentMeasurement;
    if (measurement == null) {
      return const SizedBox.shrink();
    }

    final formatted = UnitConverter.formatDistance(
      measurement.distanceMeters,
      unit: unit,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formatted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMultiLabel() {
    final multi = session.multiMeasurement;
    if (multi == null || multi.points.isEmpty) {
      return const SizedBox.shrink();
    }

    final nearest = multi.nearest;
    final farthest = multi.farthest;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (nearest != null)
            _buildStatRow(
              'Nearest',
              UnitConverter.formatDistance(nearest.distanceFromTarget, unit: unit),
              Colors.green,
            ),
          if (farthest != null)
            _buildStatRow(
              'Farthest',
              UnitConverter.formatDistance(farthest.distanceFromTarget, unit: unit),
              Colors.orange,
            ),
          const SizedBox(height: 4),
          Text(
            '${multi.points.length} points',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
