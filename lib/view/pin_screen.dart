import 'package:flutter/material.dart';
import 'package:private_diary/data/pin_repository.dart';

class PinScreen extends StatefulWidget {
  final bool isSettingPin; // true = create new PIN, false = verify existing
  const PinScreen({super.key, this.isSettingPin = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _pinRepo = PinRepository();
  String? _error;

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'PIN must be 4 digits');
      return;
    }

    if (widget.isSettingPin) {
      await _pinRepo.setPin(pin);
      if (mounted) Navigator.pop(context, true);
    } else {
      final isValid = await _pinRepo.verifyPin(pin);
      if (isValid) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _error = 'Incorrect PIN');
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 56),
              const SizedBox(height: 16),
              Text(widget.isSettingPin ? 'Set a 4-digit PIN' : 'Enter your PIN'),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12),
                decoration: InputDecoration(
                  counterText: '',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.isSettingPin ? 'Save PIN' : 'Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}