import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/news/widgets/news_detail_screen.dart';
import 'package:karang_taruna/commons/widgets/containers/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

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
      body: RefreshIndicator(
        onRefresh: controller.fetchNews,
        child: Obx(() {
          var newsList = controller.news.toList();

          if (newsList.isEmpty) {
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
              return NewsCard(
                newsItem: item,
                onTap: () {
                  Get.to(() => NewsDetailScreen(newsItem: item));
                },
              );
            },
          );
        }),
      ),
    );
  }
}
