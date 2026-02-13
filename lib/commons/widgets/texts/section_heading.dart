import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class KTSectionHeading extends StatelessWidget {
  final String title, buttonTitle;
  final void Function()? onPressed;
  final Color? titleColor;
  final Color? buttonColor;

  const KTSectionHeading({
    super.key,
    required this.title,
    this.buttonTitle = "Lihat Semua",
    this.onPressed,
    this.titleColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor ?? KTColor.textPrimary,
              fontSize: 12, // Reduced from 13
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (onPressed != null)
          GestureDetector(
            onTap: onPressed,
            child: Text(
              buttonTitle,
              style: TextStyle(
                color:
                    buttonColor ??
                    (titleColor?.withValues(alpha: 0.8) ?? KTColor.primary),
                fontSize: 9, // Reduced from 10
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
