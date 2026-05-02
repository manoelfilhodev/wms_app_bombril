import 'package:flutter/material.dart';

class Notifier {
  static void show(
    BuildContext context,
    String msg, {
    Color color = Colors.blue,
    IconData icon = Icons.info_outline,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withOpacity(0.1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void success(BuildContext context, String msg) {
    show(context, msg, color: Colors.green, icon: Icons.check_circle_outline);
  }

  static void error(BuildContext context, String msg) {
    show(context, msg, color: Colors.red, icon: Icons.error_outline);
  }

  static void warning(BuildContext context, String msg) {
    show(context, msg, color: Colors.orange, icon: Icons.warning_amber_outlined);
  }

  static void info(BuildContext context, String msg) {
    show(context, msg, color: Colors.blue, icon: Icons.info_outline);
  }
}
