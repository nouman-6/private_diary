import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:private_diary/view/pin_screen.dart';

class LockScreen extends StatefulWidget {
  final Widget child;
  const LockScreen({required this.child, super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final auth = LocalAuthentication();
  bool _unlocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock your diary',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (!mounted) return;
      setState(() {
        _unlocked = didAuthenticate;
        _isAuthenticating = false;
      });
    } on LocalAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      debugPrint('Auth error: ${e.code} - ${e.description}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BounceInDown(
  child:  Icon(Icons.lock_outline, size: 64),
),
            const SizedBox(height: 16),
            const Text('App locked'),
            const SizedBox(height: 24),
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Unlock'),
              ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PinScreen(isSettingPin: false),
                  ),
                );
                if (result == true) {
                  setState(() => _unlocked = true);
                }
              },
              child: const Text('Use PIN instead'),
            ),
          ],
        ),
      ),
    );
  }
}
