import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:private_diary/data/pin_repository.dart';

class PinScreen extends StatefulWidget {
  final bool isSettingPin;
  const PinScreen({super.key, this.isSettingPin = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _pinRepo = PinRepository();
  String? _error;
  int _shakeKey = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() {
        _error = 'PIN must be 4 digits';
        _shakeKey++;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    if (widget.isSettingPin) {
      await _pinRepo.setPin(pin);
      if (mounted) Navigator.pop(context, true);
    } else {
      final isValid = await _pinRepo.verifyPin(pin);
      if (!mounted) return;
      if (isValid) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Incorrect PIN';
          _isSubmitting = false;
          _shakeKey++;
        });
        _pinController.clear();
      }
    }
  }

  void _onChanged(String value) {
    setState(() => _error = null);
    if (value.length == 4) {
      _focusNode.unfocus();
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pin = _pinController.text;

    return Scaffold(
      body: Stack(
        children: [
          // Same decorative touch as the lock screen — uses the app's
          // existing theme colors only, no new theme is introduced.
          Positioned(
            top: -90,
            right: -70,
            child: _Blob(size: 240, color: colorScheme.primary.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Blob(size: 280, color: colorScheme.secondary.withOpacity(0.07)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  Container(
                    width: 88,
                    height: 88,
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
                      Icons.password_rounded,
                      size: 38,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeInUp(
                    from: 16,
                    child: Text(
                      widget.isSettingPin ? 'Set a 4-digit PIN' : 'Enter your PIN',
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
                      widget.isSettingPin
                          ? 'This PIN will unlock Private Diary'
                          : 'Confirm it\'s you before opening your diary',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Tap anywhere on the boxes to bring up the keyboard
                  GestureDetector(
                    onTap: () => _focusNode.requestFocus(),
                    child: ShakeX(
                      key: ValueKey(_shakeKey),
                      child: _PinBoxes(
                        pin: pin,
                        length: 4,
                        hasError: _error != null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 20,
                    child: AnimatedOpacity(
                      opacity: _error != null ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        _error ?? '',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Invisible field that actually captures keyboard input
                  SizedBox(
                    height: 0,
                    width: 0,
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _pinController,
                        focusNode: _focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: _onChanged,
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  FadeInUp(
                    from: 24,
                    delay: const Duration(milliseconds: 150),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : Text(
                                widget.isSettingPin ? 'Save PIN' : 'Unlock',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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

class _PinBoxes extends StatelessWidget {
  final String pin;
  final int length;
  final bool hasError;

  const _PinBoxes({
    required this.pin,
    required this.length,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final filled = index < pin.length;
        final isCurrent = index == pin.length;

        Color borderColor = Colors.transparent;
        if (hasError) {
          borderColor = colorScheme.error.withOpacity(0.7);
        } else if (isCurrent) {
          borderColor = colorScheme.primary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: filled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant.withOpacity(0.4),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: filled
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        );
      }),
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