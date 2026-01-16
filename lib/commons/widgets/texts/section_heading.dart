import 'package:flutter/material.dart';

class KTSectionHeading extends StatelessWidget {
  const KTSectionHeading({
    super.key,
    this.onPressed,
    required this.title,
    this.buttonTitle = "Lihat Semua",
  });

  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            buttonTitle,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
