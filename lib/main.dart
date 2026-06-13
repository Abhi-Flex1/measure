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
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    // Always request camera permission on launch
    final status = await Permission.camera.request();
    
    if (mounted) {
      setState(() => _isChecking = false);
      
      if (status.isGranted || status.isLimited) {
        _navigateToAR();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
      // If denied but not permanent, stay on this screen to retry
    }
  }

  void _navigateToAR() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ARMeasureScreen()),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera access is needed for AR measurements. '
          'Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DemoARScreen()),
              );
            },
            child: const Text('Use Demo Mode'),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.of(context).pop();
                _checkAndRequestPermission();
              }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Requesting camera access...'),
            ],
          ),
        ),
      );
    }

    // Show retry screen if permission denied
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Needed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please grant camera access to use AR measurement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _checkAndRequestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Grant Permission'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _navigateToAR,
                child: Text(
                  'Continue without AR',
                  style: TextStyle(color: Colors.white.withAlpha(150)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
