import 'package:flutter/material.dart';

enum KTEventStatus { upcoming, ongoing, completed }

class KTEventCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final KTEventStatus status;
  final String location;

  const KTEventCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.location,
  });

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF79CDB0),
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
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 3,
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
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
              if (location != null && location!.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
