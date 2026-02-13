import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

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

  Color get _statusColor {
    switch (status) {
      case KTEventStatus.upcoming:
        return KTColor.info;
      case KTEventStatus.ongoing:
        return KTColor.primary;
      case KTEventStatus.completed:
        return KTColor.textGrey;
    }
  }

  String get _statusLabel {
    switch (status) {
      case KTEventStatus.upcoming:
        return 'AKAN DATANG';
      case KTEventStatus.ongoing:
        return 'SEDANG BERLANGSUNG';
      case KTEventStatus.completed:
        return 'SELESAI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KTColor.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: KTColor.shadowWithAlpha(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KTColor.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: KTColor.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(Icons.calendar_today_rounded, formattedDate),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.access_time_rounded, formattedTime),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoItem(Icons.location_on_rounded, location),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: KTColor.textGrey),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: KTColor.textGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
