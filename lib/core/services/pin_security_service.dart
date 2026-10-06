import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PinSecurityService {
  static const String _pinKey = 'admin_security_pin';
  static const String _defaultPin = '9824';

  static String getAdminPin() {
    final box = Hive.box('settings');
    return box.get(_pinKey, defaultValue: _defaultPin) as String;
  }

  static Future<void> setAdminPin(String newPin) async {
    final box = Hive.box('settings');
    await box.put(_pinKey, newPin);
  }

  static bool verifyPin(String enteredPin) {
    final current = getAdminPin();
    return enteredPin.trim() == current.trim();
  }

  /// Displays a clean 4-digit PIN prompt modal before destructive operations.
  /// Returns `true` if authorized, `false` otherwise.
  static Future<bool> requestPinAuthorization(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final pinController = TextEditingController();
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter 4-digit Admin PIN:',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••',
                        counterText: '',
                        errorText: errorMessage,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (val) {
                        if (verifyPin(val)) {
                          Navigator.pop(ctx, true);
                        } else {
                          setModalState(() {
                            errorMessage = 'Incorrect PIN! Try again.';
                            pinController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Default PIN: 9824 (Configurable in Settings)',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (verifyPin(pinController.text)) {
                      Navigator.pop(ctx, true);
                    } else {
                      setModalState(() {
                        errorMessage = 'Incorrect PIN! Access denied.';
                        pinController.clear();
                      });
                    }
                  },
                  child: const Text('AUTHORIZE'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }
}
