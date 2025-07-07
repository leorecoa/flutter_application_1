import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool overlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}