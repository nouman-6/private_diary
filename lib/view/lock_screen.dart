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

  Future<void> _usePin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PinScreen(isSettingPin: false)),
    );
    if (result == true && mounted) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _Blob(
              size: 240,
              color: colorScheme.primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Blob(
              size: 280,
              color: colorScheme.secondary.withOpacity(0.07),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Brand mark
                  Pulse(
                    infinite: true,
                    duration: const Duration(seconds: 3),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 44,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeInUp(
                    from: 16,
                    child: Text(
                      'Private Diary',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeInUp(
                    from: 16,
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Your thoughts are safely locked away',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Primary unlock action
                  FadeInUp(
                    from: 24,
                    delay: const Duration(milliseconds: 150),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isAuthenticating ? null : _authenticate,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: _isAuthenticating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Icon(Icons.fingerprint_rounded),
                        label: Text(
                          _isAuthenticating ? 'Authenticating…' : 'Unlock',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary PIN action
                  FadeInUp(
                    from: 24,
                    delay: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isAuthenticating ? null : _usePin,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.dialpad_rounded, size: 20),
                        label: const Text(
                          'Use PIN instead',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
