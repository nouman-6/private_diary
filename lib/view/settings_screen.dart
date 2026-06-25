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

  Future<void> _confirmRemovePin(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove PIN'),
            content: const Text(
              'You will no longer be able to use a PIN as a fallback when biometrics fail.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _pinRepo.removePin();
      _checkPin();
    }
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, size: 20, color: fg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // Same faint brand touch used across the other screens.
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(context, 'APPEARANCE'),
                  Card(
                    child: SwitchListTile(
                      secondary: _iconBadge(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        colorScheme.tertiaryContainer,
                        colorScheme.onTertiaryContainer,
                      ),
                      title: const Text('Dark Mode'),
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionLabel(context, 'SECURITY'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: _iconBadge(
                            Icons.lock_outline_rounded,
                            colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer,
                          ),
                          title: Text(_hasPin ? 'Change PIN' : 'Set Backup PIN'),
                          subtitle: const Text('Use as fallback when biometrics fail'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PinScreen(isSettingPin: true),
                              ),
                            );
                            if (result == true) _checkPin();
                          },
                        ),
                        if (_hasPin) Divider(height: 1, indent: 72, color: colorScheme.outlineVariant.withOpacity(0.4)),
                        if (_hasPin)
                          ListTile(
                            leading: _iconBadge(
                              Icons.delete_outline_rounded,
                              colorScheme.errorContainer,
                              colorScheme.onErrorContainer,
                            ),
                            title: Text(
                              'Remove PIN',
                              style: TextStyle(color: colorScheme.error, fontSize: 16),
                            ),
                            onTap: () => _confirmRemovePin(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}