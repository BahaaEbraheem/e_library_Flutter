import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'حسناً',
    this.onPressed,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'حسناً',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onPressed ?? () => Navigator.pop(context),
          child: Text(buttonText),
        ),
      ],
    );
  }
}