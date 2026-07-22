import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_blog/core/extensions/build_context_extension.dart';

enum AppNotificationType { success, error }

abstract final class AppNotification {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void success(BuildContext context, {required String message}) {
    _show(context, message: message, type: AppNotificationType.success);
  }

  static void error(BuildContext context, {required String message}) {
    _show(context, message: message, type: AppNotificationType.error);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required AppNotificationType type,
  }) {
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final isCompact = context.width < 600;

        return Positioned(
          top: 16,
          right: 16,
          left: isCompact ? 16 : null,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topRight,
              child: _NotificationCard(
                message: message,
                type: type,
                onDismiss: dismiss,
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(const Duration(seconds: 2), () {
      if (identical(_currentEntry, entry)) {
        dismiss();
      }
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AppNotificationType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = type == AppNotificationType.success;
    final backgroundColor = isSuccess
        ? const Color(0xFF167D53)
        : const Color(0xFFB3261E);
    const foregroundColor = Colors.white;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: foregroundColor.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.32 : 0.14,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.error_outline_rounded,
                  size: 20,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Dismiss notification',
                visualDensity: VisualDensity.compact,
                color: foregroundColor,
                icon: const Icon(Icons.close_rounded, size: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
