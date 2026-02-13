import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: KTColor.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KTColor.shadowWithAlpha(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: enableHeaderTap ? onCardTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: KTColor.primaryWithAlpha(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.poll_rounded,
                        color: KTColor.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: KTColor.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isVoted && ratio > 0 
                                ? KTColor.primaryWithAlpha(0.05)
                                : KTColor.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isVoted && ratio > 0
                                  ? KTColor.primaryWithAlpha(0.2)
                                  : Colors.transparent,
                              width: 1.5,
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
                                        fontWeight: FontWeight.w600,
                                        color: KTColor.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isVoted) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '$percent%',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: KTColor.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (isVoted) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: KTColor.primaryWithAlpha(0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      KTColor.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$votes Suara',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: KTColor.textGrey,
                                    fontWeight: FontWeight.w500,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isVoted) ...[
                      const Icon(Icons.check_circle_rounded, size: 16, color: KTColor.primary),
                      const SizedBox(width: 6),
                      const Text(
                        "Anda sudah memilih",
                        style: TextStyle(
                          color: KTColor.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.info_outline_rounded, size: 16, color: KTColor.textGrey),
                      const SizedBox(width: 6),
                      const Text(
                        "Pilih salah satu opsi",
                        style: TextStyle(
                          color: KTColor.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      "$totalVotes Total Suara",
                      style: const TextStyle(
                        color: KTColor.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

