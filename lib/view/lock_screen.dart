import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

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
      // e.code can be checked: userCanceled, notEnrolled, lockedOut, etc.
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
            const Icon(Icons.lock_outline, size: 64),
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
          ],
        ),
      ),
    );
  }
}
