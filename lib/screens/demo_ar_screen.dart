import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/measurement_session.dart';
import '../models/point3d.dart';
import '../widgets/crosshair_overlay.dart';
import '../widgets/mode_switcher.dart';
import '../widgets/bottom_tab_bar.dart';
import '../utils/unit_converter.dart';
import 'level_screen.dart';
import 'settings_screen.dart';

class DemoARScreen extends StatefulWidget {
  const DemoARScreen({super.key});

  @override
  State<DemoARScreen> createState() => _DemoARScreenState();
}

class _DemoARScreenState extends State<DemoARScreen> {
  UnitSystem _unitSystem = UnitSystem.imperial;
  final List<DemoPoint> _placedPoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated AR Camera Background - tappable
          GestureDetector(
            onTapUp: (details) => _handleTap(details),
            child: _buildDemoBackground(),
          ),
          
          // Crosshair overlay
          const Center(
            child: CrosshairOverlay(size: 100),
          ),
          
          // Top bar
          _buildTopBar(),
          
          // Mode switcher
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Center(
              child: Consumer<MeasurementSession>(
                builder: (context, session, _) {
                  return ModeSwitcher(
                    currentMode: session.mode,
                    onModeChanged: (mode) {
                      setState(() => _placedPoints.clear());
                      session.setMode(mode);
                    },
                  );
                },
              ),
            ),
          ),
          
          // Instruction text
          if (_placedPoints.isEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tap anywhere to place points',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          
          // Placed points visualization
          ..._placedPoints.map((p) => Positioned(
            left: p.screenPosition.dx - 12,
            top: p.screenPosition.dy - 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          )),
          
          // Draw lines between points
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: _LinePainter(points: _placedPoints),
          ),
          
          // Distance labels for placed points
          ..._buildDistanceLabels(),
          
          // Demo mode banner
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Demo Mode - No AR',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: _buildBottomControls(),
          ),
          
          // Bottom tab bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomTabBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2d3436),
            Color(0xFF636e72),
            Color(0xFF2d3436),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.view_in_ar,
          size: 200,
          color: Colors.white.withAlpha(20),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final session = context.read<MeasurementSession>();
    final tapPosition = details.localPosition;

    // Create a simulated 3D point based on tap position
    final point = Point3D(
      position: vm.Vector3(
        (tapPosition.dx - MediaQuery.of(context).size.width / 2) * 0.001,
        0,
        -0.5 - (_placedPoints.length * 0.1),
      ),
    );

    setState(() {
      _placedPoints.add(DemoPoint(
        position: point,
        screenPosition: tapPosition,
      ));
    });

    session.addPoint(point);
  }

  void _handleUndo() {
    final session = context.read<MeasurementSession>();
    if (_placedPoints.isNotEmpty) {
      setState(() => _placedPoints.removeLast());
    }
    session.undo();
  }

  void _handleClear() {
    final session = context.read<MeasurementSession>();
    setState(() => _placedPoints.clear());
    session.clear();
  }

  Widget _buildBottomControls() {
    return Consumer<MeasurementSession>(
      builder: (context, session, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clear button
            if (session.hasPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGlassButton(
                  label: 'Clear',
                  icon: Icons.delete_outline,
                  onTap: _handleClear,
                ),
              ),
            
            // Control row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(
                  icon: Icons.undo,
                  onTap: session.hasPoints ? _handleUndo : null,
                ),
                
                const SizedBox(width: 24),
                
                // Point count indicator
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        size: 24,
                        color: Colors.white,
                      ),
                      if (_placedPoints.isNotEmpty)
                        Text(
                          '${_placedPoints.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                _buildCircleButton(
                  icon: Icons.straighten,
                  onTap: () {
                    setState(() {
                      _unitSystem = _unitSystem == UnitSystem.imperial
                          ? UnitSystem.metric
                          : UnitSystem.imperial;
                    });
                  },
                  label: _unitSystem == UnitSystem.imperial ? 'ft' : 'cm',
                ),
              ],
            ),
          ],
        );
      },
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
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGlassIconButton(
                icon: Icons.menu,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        currentUnit: _unitSystem == UnitSystem.imperial ? 'imperial' : 'metric',
                        onUnitChanged: (unit) {
                          setState(() {
                            _unitSystem = unit == 'imperial'
                                ? UnitSystem.imperial
                                : UnitSystem.metric;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              _buildGlassIconButton(icon: Icons.camera_alt, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  List<Widget> _buildDistanceLabels() {
    final session = context.read<MeasurementSession>();
    final labels = <Widget>[];

    if (session.mode == MeasurementMode.simple && session.currentMeasurement != null) {
      final measurement = session.currentMeasurement!;
      final formatted = UnitConverter.formatDistance(
        measurement.distanceMeters,
        unit: _unitSystem,
      );

      // Position label between the two points
      if (_placedPoints.length >= 2) {
        final p1 = _placedPoints[0].screenPosition;
        final p2 = _placedPoints[1].screenPosition;
        final midX = (p1.dx + p2.dx) / 2;
        final midY = (p1.dy + p2.dy) / 2;

        labels.add(
          Positioned(
            left: midX - 40,
            top: midY - 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            ),
          ),
        );
      }
    }

    if (session.mode == MeasurementMode.multi && session.multiMeasurement != null) {
      final multi = session.multiMeasurement!;
      
      for (var i = 0; i < multi.points.length && i < _placedPoints.length; i++) {
        final measurementPoint = multi.points[i];
        final point = _placedPoints[i + 1]; // +1 to skip target point
        final formatted = UnitConverter.formatDistance(
          measurementPoint.distanceFromTarget,
          unit: _unitSystem,
        );

        labels.add(
          Positioned(
            left: point.screenPosition.dx + 20,
            top: point.screenPosition.dy - 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                formatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }

      if (multi.points.isNotEmpty) {
        final nearest = multi.nearest;
        final farthest = multi.farthest;
        
        labels.add(
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 140,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nearest != null)
                    _buildStatRow(
                      'Nearest',
                      UnitConverter.formatDistance(nearest.distanceFromTarget, unit: _unitSystem),
                      Colors.green,
                    ),
                  if (farthest != null)
                    _buildStatRow(
                      'Farthest',
                      UnitConverter.formatDistance(farthest.distanceFromTarget, unit: _unitSystem),
                      Colors.orange,
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return labels;
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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

class DemoPoint {
  final Point3D position;
  final Offset screenPosition;

  DemoPoint({
    required this.position,
    required this.screenPosition,
  });
}

class _LinePainter extends CustomPainter {
  final List<DemoPoint> points;

  _LinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i].screenPosition;
      final end = points[i + 1].screenPosition;
      
      // Draw dashed line
      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
