import 'package:flutter/material.dart';

class KTPoolingOption {
  final int? id; // added id for voting
  final String label;
  final int value;

  const KTPoolingOption({this.id, required this.label, required this.value});
}

class KTPoolingCard extends StatelessWidget {
  final String title;
  final List<KTPoolingOption> options;
  final bool showPercentage;
  final ValueChanged<KTPoolingOption>? onOptionTap;

  const KTPoolingCard({
    super.key,
    required this.title,
    required this.options,
    this.showPercentage = true,
    this.onOptionTap,
  });

  int get _totalValue => options.fold(
    0,
    (previousValue, element) => previousValue + element.value,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _totalValue;

    return Container(
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: options.map((option) {
              final value = option.value;
              final ratio = total > 0 ? value / total : 0.0;
              final percent = (ratio * 100).round();

              Widget row = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (showPercentage) ...[
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: ratio.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFE0F2F1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF00BA9B),
                      ),
                    ),
                  ),
                ],
              );

              if (onOptionTap != null) {
                row = InkWell(
                  onTap: () => onOptionTap!(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: row,
                  ),
                );
              } else {
                row = Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: row,
                );
              }

              return row;
            }).toList(),
          ),
        ],
      ),
    );
  }
}
