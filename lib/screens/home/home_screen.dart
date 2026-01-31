import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/buttons/button_fitur.dart';
import 'package:karang_taruna/commons/widgets/containers/announcement_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/banner.dart';
import 'package:karang_taruna/commons/widgets/containers/pooling_card.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';
import 'package:karang_taruna/commons/widgets/texts/section_heading.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_screen.dart';
import 'package:karang_taruna/screens/event/event_screen.dart';
import 'package:karang_taruna/screens/finance/finance_screen.dart';
import 'package:karang_taruna/screens/gallery/gallery_screen.dart';
import 'package:karang_taruna/screens/management/management_screen.dart';
import 'package:karang_taruna/screens/news/news_screen.dart';
import 'package:karang_taruna/screens/polling/polling_screen.dart';
import 'package:karang_taruna/screens/settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: const Color(0xFF00BA9B),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const HeaderHome(),
                const NewsHome(),
                const AnnouncementHome(),
                const PojokKampungHome(),
                const PoolingHome(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PoolingHome extends StatelessWidget {
  const PoolingHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Pooling",
            onPressed: () => Get.to(() => const PollingScreen()),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingPolls.value && controller.polls.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (controller.polls.isEmpty) {
              return const SizedBox.shrink();
            }

            // Get the latest active poll
            final poll = controller.polls.first;
            final options = List<Map<String, dynamic>>.from(
              poll['polling_options'] ?? [],
            );
            final totalVotes = options.fold<int>(
              0,
              (sum, item) => sum + (item['vote_count'] as int? ?? 0),
            );
            final pollId = poll['id'];
            final hasVoted = controller.votedPollIds.contains(pollId);

            return KTPollingCard(
              question: poll['title'],
              options: options,
              totalVotes: totalVotes,
              isVoted: hasVoted,
              onVote: (optionId, label) async {
                if (hasVoted) {
                  Get.snackbar(
                    'Info',
                    'Anda sudah memilih pada polling ini',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                  return;
                }
                await controller.votePoll(pollId, optionId);
                Get.snackbar(
                  'Sukses',
                  'Terima kasih atas partisipasi Anda!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class PojokKampungHome extends StatelessWidget {
  const PojokKampungHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Pojok Kampung",
            onPressed: () => Get.to(() => const AspirationScreen()),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingAspirations.value &&
                controller.allAspirations.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (controller.allAspirations.isEmpty) {
              return const Text(
                'Belum ada aspirasi',
                style: TextStyle(color: Colors.white),
              );
            }

            // Show top 3 aspirations
            return Column(
              children: [
                ...controller.allAspirations
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: KTAspirationCard(
                          author: item['author'] ?? 'Anonim',
                          content: item['content'],
                          createdAt:
                              DateTime.tryParse(item['created_at']) ??
                              DateTime.now(),
                          status: item['status'] ?? 'pending',
                          onTap: () {}, // Detail view could be added later
                        ),
                      ),
                    ),
                KTAspirationBanner(
                  onTap: () => Get.to(() => const AspirationScreen()),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class AnnouncementHome extends StatelessWidget {
  const AnnouncementHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Pengumuman Terbaru",
            onPressed: () {
              // Navigate to full list if needed, currently no dedicated screen
              // defaulting to nothing or maybe a dialog
            },
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.announcements.isEmpty) {
              return const Text(
                'Tidak ada pengumuman',
                style: TextStyle(color: Colors.white),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.announcements.length > 3
                  ? 3
                  : controller.announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.announcements[index];
                return KTAnnouncementCard(
                  title: item['title'],
                  description: item['description'] ?? '',
                  badgeText: item['badge_text'] ?? 'Info',
                  onTap: () {},
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class NewsHome extends StatelessWidget {
  const NewsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Berita Terbaru",
            onPressed: () => Get.to(() => const NewsScreen()),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.news.isEmpty) {
              return const Text(
                'Tidak ada berita',
                style: TextStyle(color: Colors.white),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 9 / 11,
              ),
              itemCount: controller.news.length > 4
                  ? 4
                  : controller.news.length,
              itemBuilder: (context, index) {
                final item = controller.news[index];
                return KTPostContainer(
                  imageUrl:
                      item['image_url'] ?? "https://picsum.photos/400/300",
                  title: item['title'],
                  author: item['author'] ?? 'Admin',
                  createdAt:
                      DateTime.tryParse(item['created_at']) ?? DateTime.now(),
                  content: item['content'] ?? '',
                  category: item['category'] ?? 'News',
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 20),
      decoration: const BoxDecoration(
        color: Color(0xff79CDB0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final name =
                controller.userProfile['full_name']?.toString() ?? 'User';
            return Text(
              'Hi, $name!',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () => Get.to(() => const ManagementScreen()),
              ),
              KTButtonFitur(
                icon: Icons.photo_library,
                label: "Galeri",
                onTap: () => Get.to(() => const GalleryScreen()),
              ),
              KTButtonFitur(
                icon: Icons.attach_money,
                label: "Keuangan",
                onTap: () => Get.to(() => const FinanceScreen()),
              ),
              KTButtonFitur(
                icon: Icons.event,
                label: "Event",
                onTap: () => Get.to(() => const EventScreen()),
              ),
              KTButtonFitur(
                icon: Icons.newspaper,
                label: "Berita",
                onTap: () => Get.to(() => const NewsScreen()),
              ),
              KTButtonFitur(
                icon: Icons.people_alt,
                label: "Pooling",
                onTap: () => Get.to(() => const PollingScreen()),
              ),
              KTButtonFitur(
                icon: Icons.feedback,
                label: "Aspirasi",
                onTap: () => Get.to(() => const AspirationScreen()),
              ),
              KTButtonFitur(
                icon: Icons.settings,
                label: "Pengaturan",
                onTap: () => Get.to(() => const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
