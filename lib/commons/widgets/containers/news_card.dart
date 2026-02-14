import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';

/// A wrapper widget for [KTPostContainer] specifically for news items.
class NewsCard extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.newsItem, this.onTap});

  @override
  Widget build(BuildContext context) {
    return KTPostContainer(
      imageUrl: newsItem['image_url'] ?? "https://picsum.photos/400/300",
      title: newsItem['title'] ?? 'No Title',
      author: newsItem['author'] ?? 'Admin',
      createdAt:
          DateTime.tryParse(newsItem['created_at'] ?? '') ?? DateTime.now(),
      content: newsItem['content'] ?? '',
      category: newsItem['category'] ?? 'Berita',
      onTap: onTap,
    );
  }
}

class NewsCompactCard extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onTap;

  const NewsCompactCard({super.key, required this.newsItem, this.onTap});

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return '$day/$month/$year';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'A';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    final initials = (first + last).toUpperCase();
    return initials.isNotEmpty ? initials : 'A';
  }

  String _clampText(String text, int maxChars) {
    final trimmed = text.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars - 1)}…';
  }

  @override
  Widget build(BuildContext context) {
    final title = newsItem['title'] ?? 'No Title';
    final author = newsItem['author'] ?? 'Admin';
    final createdAt =
        DateTime.tryParse(newsItem['created_at'] ?? '') ?? DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: KTColor.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: KTColor.shadowWithAlpha(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: KTColor.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KTColor.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: KTColor.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: KTColor.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(author),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: KTColor.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_rounded,
                                  size: 12,
                                  color: KTColor.textGrey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _clampText(author, 22),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: KTColor.textGrey,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: KTColor.textGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: KTColor.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 24,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: KTColor.textGrey,
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
