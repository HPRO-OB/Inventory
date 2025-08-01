import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
  leading: TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('<', style: TextStyle(fontSize: 16)),
  ),
  title: const Text('Settings'),
),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onThemeToggle,
            ),
          ),
        ],
      ),
    );
  }
}
