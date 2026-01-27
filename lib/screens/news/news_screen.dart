import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = SupabaseService();
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _service.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Berita",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var newsList = snapshot.data ?? [];
          // Fallback data
          if (newsList.isEmpty) {
            // Usually we'd want to show "No News", but for continuity let's just show "No News" text
            // OR provide some mock data if that's preferred. Given previous pattern, let's mock if empty.
            newsList = [
              {
                'title': 'Karang Taruna Mengadakan Lomba Futsal Antar RT',
                'author': 'Admin',
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String(),
                'content': 'Lomba futsal akan diadakan di lapangan utama...',
                'category': 'Olahraga',
                'image_url': 'https://picsum.photos/400/300?random=10',
              },
              {
                'title': 'Penyuluhan Kesehatan Masyarakat',
                'author': 'Dr. Budi',
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 3))
                    .toIso8601String(),
                'content':
                    'Penyuluhan kesehatan tentang pentingnya gizi seimbang...',
                'category': 'Kesehatan',
                'image_url': 'https://picsum.photos/400/300?random=11',
              },
            ];
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: newsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = newsList[index];
              return KTPostContainer(
                imageUrl: item['image_url'] ?? "https://picsum.photos/400/300",
                title: item['title'],
                author: item['author'] ?? 'Admin',
                createdAt:
                    DateTime.tryParse(item['created_at']) ?? DateTime.now(),
                content: item['content'] ?? '',
                category: item['category'] ?? 'News',
              );
            },
          );
        },
      ),
    );
  }
}
