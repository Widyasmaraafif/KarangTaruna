import 'package:flutter/material.dart';

class KTBillingItem {
  final String title;
  final String description;
  final int amount;
  final DateTime dueDate;

  const KTBillingItem({
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
  });
}

class KTBillingCard extends StatelessWidget {
  final KTBillingItem bill;

  const KTBillingCard({super.key, required this.bill});

  String get formattedAmount {
    final value = bill.amount;
    final buffer = StringBuffer();
    final text = value.toString();
    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  String get formattedDueDate {
    final day = bill.dueDate.day.toString().padLeft(2, '0');
    final month = bill.dueDate.month.toString().padLeft(2, '0');
    final year = bill.dueDate.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff79CDB0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bill.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formattedAmount,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bill.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Jatuh tempo $formattedDueDate',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
