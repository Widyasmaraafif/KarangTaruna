import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';

/// A wrapper widget for [KTPostContainer] specifically for news items.
class NewsCard extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.newsItem, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Map dynamic data from API/Controller to KTPostContainer properties
    return KTPostContainer(
      imageUrl: newsItem['image_url'] ?? "https://picsum.photos/400/300",
      title: newsItem['title'] ?? 'No Title',
      author: newsItem['author'] ?? 'Admin',
      createdAt:
          DateTime.tryParse(newsItem['created_at'] ?? '') ?? DateTime.now(),
      content: newsItem['content'] ?? '',
      category: newsItem['category'] ?? 'News',
      onTap: onTap,
    );
  }
}
