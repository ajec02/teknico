// Widget de Preloader Elegante e Extravagante no Estilo Hyper POS

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExtravagantPreloader extends StatelessWidget {
  final String message;

  const ExtravagantPreloader({
    super.key,
    this.message = 'A processar...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFFFF6B00);

    return Container(
      color: (isDark ? const Color(0xFF0B0C0E) : Colors.white).withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141519) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.25),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinKitFadingCube(
                color: accentColor,
                size: 45.0,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
