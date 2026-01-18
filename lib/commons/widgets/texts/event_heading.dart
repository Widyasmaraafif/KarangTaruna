import 'package:flutter/material.dart';

class KTEventHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const KTEventHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF79CDB0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                size: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
