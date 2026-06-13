import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String currentUnit;
  final ValueChanged<String> onUnitChanged;

  const SettingsScreen({
    super.key,
    required this.currentUnit,
    required this.onUnitChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.currentUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Units section
          _buildSectionHeader('Measurement Units'),
          _buildUnitOption(
            label: 'Imperial (Feet & Inches)',
            value: 'imperial',
            icon: Icons.straighten,
          ),
          _buildUnitOption(
            label: 'Metric (Meters & Centimeters)',
            value: 'metric',
            icon: Icons.science,
          ),

          const SizedBox(height: 32),

          // About section
          _buildSectionHeader('About'),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'AR Measure',
            subtitle: 'Version 1.0.0',
          ),
          _buildInfoTile(
            icon: Icons.code,
            title: 'GitHub',
            subtitle: 'github.com/Abhi-Flex1/measure',
            onTap: () {
              // TODO: Open GitHub URL
            },
          ),

          const SizedBox(height: 32),

          // Credits
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Built with Flutter & ARCore/ARKit',
              style: TextStyle(
                color: Colors.white.withAlpha(100),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withAlpha(150),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildUnitOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedUnit == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : Icon(Icons.circle_outlined, color: Colors.white.withAlpha(100)),
      onTap: () {
        setState(() => _selectedUnit = value);
        widget.onUnitChanged(value);
        _saveUnitPreference(value);
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withAlpha(150)),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.white.withAlpha(100))
          : null,
      onTap: onTap,
    );
  }

  Future<void> _saveUnitPreference(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unit_preference', unit);
  }
}
