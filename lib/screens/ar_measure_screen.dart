import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/measurement_session.dart';
import '../models/point3d.dart';
import '../widgets/crosshair_overlay.dart';
import '../widgets/mode_switcher.dart';
import '../widgets/bottom_tab_bar.dart';
import '../utils/unit_converter.dart';
import 'level_screen.dart';
import 'settings_screen.dart';

class ARMeasureScreen extends StatefulWidget {
  const ARMeasureScreen({super.key});

  @override
  State<ARMeasureScreen> createState() => _ARMeasureScreenState();
}

class _ARMeasureScreenState extends State<ARMeasureScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  
  UnitSystem _unitSystem = UnitSystem.imperial;
  bool _isARReady = false;
  String? _arError;
  
  final List<ARMeasurementPoint> _arPoints = [];
  final List<ARNode> _placedNodes = [];

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      showAnimatedGuide: true,
    );

    arObjectManager.onInitialize();

    arSessionManager.onPlaneOrPointTap = _handleARHitTest;
    
    setState(() {
      _isARReady = true;
    });
  }

  void _handleARHitTest(List<ARHitTestResult> results) {
    if (results.isEmpty) return;

    final hit = results.first;
    final worldTransform = hit.worldTransform;
    final translation = worldTransform.getTranslation();

    final session = context.read<MeasurementSession>();
    final point = Point3D(position: translation);

    setState(() {
      _arPoints.add(ARMeasurementPoint(
        position: point,
        distance: hit.distance,
      ));
    });

    _placeMarkerAtPoint(point);
    session.addPoint(point);
  }

  Future<void> _placeMarkerAtPoint(Point3D point) async {
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "https://github.com/nickvdyck/ar_flutter_plugin/raw/master/example/assets/Origin/models/origin.gltf",
      scale: vm.Vector3(0.01, 0.01, 0.01),
      position: vm.Vector3(point.x, point.y, point.z),
      rotation: vm.Vector4(0, 0, 0, 0),
    );

    bool? didAddNode = await arObjectManager.addNode(node);
    if (didAddNode == true) {
      _placedNodes.add(node);
    }
  }

  void _handleUndo() {
    final session = context.read<MeasurementSession>();
    
    if (_arPoints.isNotEmpty) {
      _arPoints.removeLast();
    }
    
    if (_placedNodes.isNotEmpty) {
      final lastNode = _placedNodes.removeLast();
      arObjectManager.removeNode(lastNode);
    }
    
    session.undo();
  }

  void _handleClear() {
    final session = context.read<MeasurementSession>();
    
    for (var node in _placedNodes) {
      arObjectManager.removeNode(node);
    }
    _arPoints.clear();
    _placedNodes.clear();
    
    session.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // AR Camera View - tappable for point placement
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          
          // Crosshair overlay - visual indicator for aim point
          const Center(
            child: CrosshairOverlay(size: 100),
          ),
          
          // Instruction text
          if (_isARReady && _arPoints.isEmpty)
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
                    'Tap anywhere to place first point',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
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
                      _handleClear();
                      session.setMode(mode);
                    },
                  );
                },
              ),
            ),
          ),
          
          // Error overlay
          if (_arError != null) _buildErrorOverlay(),
          
          // AR status indicator
          if (!_isARReady) _buildLoadingOverlay(),
          
          // Distance labels for placed points
          ..._buildDistanceLabels(),
          
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
                // Undo button
                _buildCircleButton(
                  icon: Icons.undo,
                  onTap: session.hasPoints ? _handleUndo : null,
                ),
                
                const SizedBox(width: 24),
                
                // Center indicator (shows point count)
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
                      Icon(
                        Icons.touch_app,
                        size: 24,
                        color: Colors.white,
                      ),
                      if (_arPoints.isNotEmpty)
                        Text(
                          '${_arPoints.length}',
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
                
                // Unit toggle
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

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _arError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _arError = null;
                    _isARReady = false;
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Initializing AR...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
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
              _buildGlassIconButton(
                icon: Icons.camera_alt,
                onTap: () async {
                  if (_isARReady) {
                    await arSessionManager.snapshot();
                  }
                },
              ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Simple mode - show distance between point A and B
    if (session.mode == MeasurementMode.simple && session.currentMeasurement != null) {
      final measurement = session.currentMeasurement!;
      final formatted = UnitConverter.formatDistance(
        measurement.distanceMeters,
        unit: _unitSystem,
      );

      labels.add(
        Positioned(
          left: screenWidth / 2 - 50,
          top: screenHeight / 2 + 70,
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

    // Multi mode - show distances from target to each point
    if (session.mode == MeasurementMode.multi && session.multiMeasurement != null) {
      final multi = session.multiMeasurement!;
      
      // Show distances next to each point marker
      for (var i = 0; i < multi.points.length; i++) {
        final measurementPoint = multi.points[i];
        final formatted = UnitConverter.formatDistance(
          measurementPoint.distanceFromTarget,
          unit: _unitSystem,
        );

        labels.add(
          Positioned(
            left: screenWidth / 2 + 40,
            top: screenHeight / 2 - 10 + (i * 35),
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

      // Show nearest/farthest stats panel
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

class ARMeasurementPoint {
  final Point3D position;
  final double distance;

  ARMeasurementPoint({
    required this.position,
    required this.distance,
  });
}
