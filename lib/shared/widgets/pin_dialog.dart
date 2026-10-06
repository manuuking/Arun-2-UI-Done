import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinDialog({super.key, required this.onSuccess});

  static Future<void> show(BuildContext context, VoidCallback onSuccess) async {
    return showDialog(
      context: context,
      builder: (ctx) => PinDialog(onSuccess: onSuccess),
    );
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _pinCtrl = TextEditingController();
  String? _error;

  void _submit() {
    if (_pinCtrl.text.trim() == '9824') {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      setState(() {
        _error = 'Invalid PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Security Verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please enter the security PIN to proceed with this destructive action.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(labelText: 'PIN', errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Verify')),
      ],
    );
  }
}
