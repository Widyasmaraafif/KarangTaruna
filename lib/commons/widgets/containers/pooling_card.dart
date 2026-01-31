import 'package:flutter/material.dart';

class KTPollingCard extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> options;
  final int totalVotes;
  final bool isVoted;
  final Function(int optionId, String label)? onVote;

  const KTPollingCard({
    super.key,
    required this.question,
    required this.options,
    required this.totalVotes,
    this.isVoted = false,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff79CDB0),
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
            question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: options.map((option) {
              final optionId = option['id'];
              final label = option['label'] ?? 'Option';
              final votes = (option['vote_count'] as num? ?? 0).toInt();

              final ratio = totalVotes > 0 ? votes / totalVotes : 0.0;
              final percent = (ratio * 100).round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: isVoted || onVote == null
                      ? null
                      : () => onVote!(optionId, label),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isVoted
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percent%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF00BA9B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00BA9B),
                            ),
                          ),
                        ),
                        if (isVoted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$votes Suara',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (isVoted)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    "Anda sudah memilih",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
