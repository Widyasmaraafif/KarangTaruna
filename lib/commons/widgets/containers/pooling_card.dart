import 'package:flutter/material.dart';

class KTPollingCard extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> options;
  final int totalVotes;
  final bool isVoted;
  final Function(int optionId, String label)? onVote;
  final VoidCallback? onCardTap;
  final bool enableHeaderTap;

  const KTPollingCard({
    super.key,
    required this.question,
    required this.options,
    required this.totalVotes,
    this.isVoted = false,
    this.onVote,
    this.onCardTap,
    this.enableHeaderTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enableHeaderTap ? onCardTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BA9B).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.poll_outlined,
                        color: Color(0xFF00BA9B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: options.map((option) {
                    final optionId = option['id'];
                    final label = option['label'] ?? 'Option';
                    final votes = (option['vote_count'] as num? ?? 0).toInt();

                    final ratio = totalVotes > 0 ? votes / totalVotes : 0.0;
                    final percent = (ratio * 100).round();

                    // Check if this option is the winner (most votes) if voted
                    // But for now just simple display
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: isVoted || onVote == null
                            ? null
                            : () => onVote!(optionId, label),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isVoted) ...[
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
                                ],
                              ),
                              if (isVoted) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF00BA9B),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$votes Suara',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (isVoted)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF00BA9B)),
                        const SizedBox(width: 4),
                        Text(
                          "Anda sudah memilih",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$totalVotes Total Suara",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                         Text(
                          "$totalVotes Total Suara",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
