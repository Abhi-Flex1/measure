import 'package:flutter/material.dart';
import '../models/measurement_session.dart';
import '../utils/unit_converter.dart';

class MeasurementControls extends StatelessWidget {
  final MeasurementSession session;
  final VoidCallback onAddPoint;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onToggleUnit;
  final UnitSystem currentUnit;

  const MeasurementControls({
    super.key,
    required this.session,
    required this.onAddPoint,
    required this.onUndo,
    required this.onClear,
    required this.onToggleUnit,
    required this.currentUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear button at top
        if (session.hasPoints)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildGlassButton(
              label: 'Clear',
              icon: Icons.delete_outline,
              onTap: onClear,
            ),
          ),
        
        // Main control row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Undo button
            _buildCircleButton(
              icon: Icons.undo,
              onTap: session.hasPoints ? onUndo : null,
            ),
            
            const SizedBox(width: 24),
            
            // Add point button (main)
            _buildAddButton(),
            
            const SizedBox(width: 24),
            
            // Unit toggle
            _buildCircleButton(
              icon: Icons.straighten,
              onTap: onToggleUnit,
              label: currentUnit == UnitSystem.imperial ? 'ft' : 'cm',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    final canAdd = session.canAddPoint;
    final hint = _getHintText();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hint text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hint,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Button
        GestureDetector(
          onTap: canAdd ? onAddPoint : null,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: canAdd ? Colors.white : Colors.white30,
              shape: BoxShape.circle,
              boxShadow: canAdd ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Icon(
              Icons.add,
              size: 32,
              color: canAdd ? Colors.black : Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    VoidCallback? onTap,
    String? label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white38 : Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: onTap != null ? Colors.white : Colors.white38,
            ),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: onTap != null ? Colors.white : Colors.white38,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    if (session.mode == MeasurementMode.simple) {
      if (session.pointA == null) {
        return 'Add first point';
      } else if (session.pointB == null) {
        return 'Add second point';
      } else {
        return 'Tap to start new';
      }
    } else {
      if (session.multiMeasurement == null) {
        return 'Set target point';
      } else {
        return 'Add measurement point';
      }
    }
  }
}
