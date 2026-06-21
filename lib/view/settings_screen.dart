import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:private_diary/data/pin_repository.dart';
import 'package:private_diary/provider/theme_provider.dart';
import 'package:private_diary/view/pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _pinRepo = PinRepository();
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final hasPin = await _pinRepo.hasPin();
    setState(() => _hasPin = hasPin);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
          ),
          ListTile(
            title: Text(_hasPin ? 'Change PIN' : 'Set Backup PIN'),
            subtitle: const Text('Use as fallback when biometrics fail'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const PinScreen(isSettingPin: true)),
              );
              if (result == true) _checkPin();
            },
          ),
          if (_hasPin)
            ListTile(
              title: const Text('Remove PIN'),
              titleTextStyle: const TextStyle(color: Colors.red, fontSize: 16),
              onTap: () async {
                await _pinRepo.removePin();
                _checkPin();
              },
            ),
        ],
      ),
    );
  }
}