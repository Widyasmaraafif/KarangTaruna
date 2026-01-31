import 'package:flutter/material.dart';

class KTAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;

  const KTAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = 'Hapus',
    this.cancelText = 'Batal',
    this.onCancel,
    this.confirmColor = Colors.red,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Hapus',
    String cancelText = 'Batal',
    Color confirmColor = Colors.red,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => KTAlertDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onCancel != null) onCancel!();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
