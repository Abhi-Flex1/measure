import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/measurement_session.dart';
import 'screens/ar_measure_screen.dart';
import 'screens/demo_ar_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ARMeasureApp());
}

class ARMeasureApp extends StatelessWidget {
  const ARMeasureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeasurementSession(),
      child: MaterialApp(
        title: 'AR Measure',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const PermissionGate(),
      ),
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _hasPermission = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted || status.isLimited) {
      setState(() {
        _hasPermission = true;
        _isChecking = false;
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    
    setState(() {
      _hasPermission = status.isGranted || status.isLimited;
    });

    if (!_hasPermission) {
      if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera permission is required for AR measurements. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasPermission) {
      return const ARMeasureScreen();
    }

    return _buildPermissionDeniedView();
  }

  Widget _buildPermissionDeniedView() {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'AR Measure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Camera access is required to use AR measurement features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Grant Camera Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const DemoARScreen(),
                    ),
                  );
                },
                child: Text(
                  'Continue without AR (Demo Mode)',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
