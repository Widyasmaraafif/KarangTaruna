import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class KTButtonFitur extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const KTButtonFitur({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 2,
          ), // Reduced padding
          decoration: BoxDecoration(
            color: KTColor.card,
            borderRadius: BorderRadius.circular(10), // Slightly smaller radius
            boxShadow: [
              BoxShadow(
                color: KTColor.shadowWithAlpha(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: KTColor.iconPrimary,
              ), // Reduced from 22
              const SizedBox(height: 3), // Reduced from 4
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 9, // Reduced from 10
                      fontWeight: FontWeight.w600,
                      color: KTColor.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
