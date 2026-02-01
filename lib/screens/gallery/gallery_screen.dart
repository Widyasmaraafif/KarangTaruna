import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/gallery/widgets/gallery_detail_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Galeri",
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
        onRefresh: controller.fetchGallery,
        child: Obx(() {
          var images = controller.gallery.toList();

          // Fallback data if API returns empty
          if (images.isEmpty) {
            images = [
              {
                'image_url': 'https://picsum.photos/400/400?random=1',
                'caption': 'Kegiatan 17 Agustus',
              },
              {
                'image_url': 'https://picsum.photos/400/400?random=2',
                'caption': 'Rapat Bulanan',
              },
              {
                'image_url': 'https://picsum.photos/400/400?random=3',
                'caption': 'Kerja Bakti',
              },
              {
                'image_url': 'https://picsum.photos/400/400?random=4',
                'caption': 'Pelatihan Pemuda',
              },
              {
                'image_url': 'https://picsum.photos/400/400?random=5',
                'caption': 'Buka Bersama',
              },
              {
                'image_url': 'https://picsum.photos/400/400?random=6',
                'caption': 'Olahraga Pagi',
              },
            ];
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => GalleryDetailScreen(
                      imageUrl:
                          image['image_url'] ?? 'https://picsum.photos/400/400',
                      caption: image['caption'] ?? '',
                    ),
                    transition: Transition.fadeIn,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: image['image_url'] ?? 'image_$index',
                        child: Image.network(
                          image['image_url'] ?? 'https://picsum.photos/400/400',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            image['caption'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
