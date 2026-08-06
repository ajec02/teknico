// Modal Personalizada Extravagante no Estilo Hyper POS (ModalT)

import 'package:flutter/material.dart';

enum ModalType { info, success, warning, error, confirm }

class CustomModal extends StatelessWidget {
  final String title;
  final String message;
  final ModalType type;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;

  const CustomModal({
    super.key,
    required this.title,
    required this.message,
    this.type = ModalType.info,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    ModalType type = ModalType.info,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: type != ModalType.confirm,
      builder: (ctx) => CustomModal(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    ModalType type = ModalType.confirm,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: type,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
    );
  }

  Color _getPrimaryColor(bool isDark) {
    switch (type) {
      case ModalType.success:
        return const Color(0xFF10B981);
      case ModalType.warning:
        return const Color(0xFFF59E0B);
      case ModalType.error:
        return const Color(0xFFEF4444);
      case ModalType.confirm:
        return const Color(0xFFFF6B00);
      case ModalType.info:
        return const Color(0xFFFF6B00);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ModalType.success:
        return Icons.check_circle_rounded;
      case ModalType.warning:
        return Icons.warning_amber_rounded;
      case ModalType.error:
        return Icons.error_outline_rounded;
      case ModalType.confirm:
        return Icons.help_outline_rounded;
      case ModalType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _getPrimaryColor(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141519) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (type == ModalType.confirm) ...[
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onConfirm != null) onConfirm!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
