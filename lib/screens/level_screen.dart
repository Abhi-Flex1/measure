import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  double _roll = 0;
  double _pitch = 0;
  bool _isLevel = false;
  bool _holdMode = false;
  double _heldRoll = 0;
  double _heldPitch = 0;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (event) {
        if (!_holdMode) {
          setState(() {
            _roll = event.x;
            _pitch = event.y;
            _isLevel = (event.x.abs() < 0.1 && event.y.abs() < 0.1);
          });
        }
      },
    );
  }

  void _toggleHold() {
    setState(() {
      _holdMode = !_holdMode;
      if (_holdMode) {
        _heldRoll = _roll;
        _heldPitch = _pitch;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLevel ? Colors.green.shade900 : const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    'Level',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildGlassButton(
                    icon: Icons.info_outline,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Main level display
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Degree display
                    Text(
                      '${(_holdMode ? _heldPitch : _pitch).toStringAsFixed(1)}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLevel ? 'LEVEL' : 'NOT LEVEL',
                      style: TextStyle(
                        color: _isLevel ? Colors.green : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Bubble level
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _BubbleLevelPainter(
                          roll: _holdMode ? _heldRoll : _roll,
                          pitch: _holdMode ? _heldPitch : _pitch,
                          isLevel: _isLevel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _holdMode ? Icons.lock : Icons.lock_open,
                    label: _holdMode ? 'Locked' : 'Lock',
                    onTap: _toggleHold,
                    isActive: _holdMode,
                  ),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    onTap: () {
                      setState(() {
                        _roll = 0;
                        _pitch = 0;
                        _holdMode = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, VoidCallback? onTap}) {
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

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isActive ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleLevelPainter extends CustomPainter {
  final double roll;
  final double pitch;
  final bool isLevel;

  _BubbleLevelPainter({
    required this.roll,
    required this.pitch,
    required this.isLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final outerPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    // Inner circles
    final innerPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.7, innerPaint);
    canvas.drawCircle(center, radius * 0.4, innerPaint);

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crosshairPaint,
    );

    // Center dot
    final centerDotPaint = Paint()
      ..color = isLevel ? Colors.green : Colors.white54
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDotPaint);

    // Bubble
    final bubbleOffset = Offset(
      center.dx + (roll * 15).clamp(-radius * 0.6, radius * 0.6),
      center.dy + (pitch * 15).clamp(-radius * 0.6, radius * 0.6),
    );

    final bubblePaint = Paint()
      ..color = isLevel ? Colors.green : Colors.white
      ..style = PaintingStyle.fill;

    final bubbleStrokePaint = Paint()
      ..color = isLevel ? Colors.greenAccent : Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(bubbleOffset, 14, bubblePaint);
    canvas.drawCircle(bubbleOffset, 14, bubbleStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
