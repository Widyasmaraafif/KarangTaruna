import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/news/widgets/news_detail_screen.dart';
import 'package:karang_taruna/commons/widgets/containers/news_card.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Berita'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchNews,
        color: KTColor.primary,
        child: Obx(() {
          var newsList = controller.news.toList();

          if (newsList.isEmpty && !controller.isLoadingNews.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.newspaper_rounded,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada berita',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          if (controller.isLoadingNews.value && newsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: newsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = newsList[index];
              return NewsCard(
                newsItem: item,
                onTap: () {
                  Get.to(
                    () => NewsDetailScreen(newsItem: item),
                    transition: Transition.cupertino,
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
