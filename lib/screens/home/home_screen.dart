import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/button_fitur.dart';
import 'package:karang_taruna/commons/widgets/containers/announcement_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/banner.dart';
import 'package:karang_taruna/commons/widgets/containers/news_card.dart';
import 'package:karang_taruna/commons/widgets/containers/polling_card.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';
import 'package:karang_taruna/commons/widgets/texts/section_heading.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/announcement/announcement_screen.dart';
import 'package:karang_taruna/screens/aspiration/all_aspirations_screen.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_detail_screen.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_screen.dart';
import 'package:karang_taruna/screens/event/event_screen.dart';
import 'package:karang_taruna/screens/gallery/gallery_screen.dart';
import 'package:karang_taruna/screens/management/management_screen.dart';
import 'package:karang_taruna/screens/finance/organization_finance_screen.dart';
import 'package:karang_taruna/screens/news/news_screen.dart';
import 'package:karang_taruna/screens/news/widgets/news_detail_screen.dart';
import 'package:karang_taruna/screens/polling/polling_detail_screen.dart';
import 'package:karang_taruna/screens/polling/polling_screen.dart';
import 'package:karang_taruna/screens/settings/settings_screen.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: KTColor.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: const [
                HeaderHome(),
                NewsHome(),
                AnnouncementHome(),
                PojokKampungHome(),
                PollingHome(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PollingHome extends StatelessWidget {
  const PollingHome({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Polling",
            onPressed: () => Get.to(() => const PollingScreen()),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingPolls.value && controller.polls.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: KTColor.primary),
                ),
              );
            }

            if (controller.polls.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Tidak ada pooling saat ini',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ),
              );
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

            final selectedByUser = controller.votedOptionByPoll[pollId];
            return KTPollingCard(
              question: poll['title'],
              options: options,
              totalVotes: totalVotes,
              isVoted: hasVoted,
              selectedOptionId: selectedByUser,
              onCardTap: () => Get.to(() => PollingDetailScreen(poll: poll)),
              onVote: (optionId, label) async {
                if (hasVoted) {
                  Get.snackbar(
                    'Info',
                    'Anda sudah memilih pada polling ini',
                    backgroundColor: KTColor.warning,
                    colorText: Colors.white,
                  );
                  return;
                }
                try {
                  await controller.votePoll(pollId, optionId);
                  Get.snackbar(
                    'Sukses',
                    'Terima kasih atas partisipasi Anda!',
                    backgroundColor: KTColor.success,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  final message = e.toString().replaceAll('Exception: ', '');
                  Get.snackbar(
                    'Info',
                    message,
                    backgroundColor: KTColor.warning,
                    colorText: Colors.white,
                  );
                }
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Pojok Kampung",
            onPressed: () => Get.to(() => const AllAspirationsScreen()),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingAspirations.value &&
                controller.allAspirations.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: KTColor.primary),
                ),
              );
            }

            if (controller.allAspirations.isEmpty) {
              return const Text(
                'Belum ada aspirasi',
                style: TextStyle(color: KTColor.textSecondary),
              );
            }

            // Show top 2 aspirations
            return Column(
              children: [
                ...controller.allAspirations
                    .take(2)
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
                          onTap: () => Get.to(
                            () => AspirationDetailScreen(aspiration: item),
                          ),
                        ),
                      ),
                    ),
                KTAspirationBanner(
                  onTap: () {
                    final roleVal =
                        controller.userProfile['role']
                            ?.toString()
                            .toLowerCase() ??
                        '';
                    final bool isGuest = roleVal.isEmpty || roleVal == 'user';

                    if (isGuest) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.block_rounded,
                                    size: 64,
                                    color: KTColor.border,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Maaf, Anda bukan Anggota Cahya Muda',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: KTColor.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fitur aspirasi hanya dapat digunakan oleh Anggota Cahya Muda.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: KTColor.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(),
                                      child: const Text('Tutup'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      return;
                    }

                    Get.to(() => const AspirationScreen());
                  },
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Pengumuman Terbaru",
            onPressed: () {
              Get.to(() => const AnnouncementScreen());
            },
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.announcements.isEmpty) {
              return const Text(
                'Tidak ada pengumuman',
                style: TextStyle(color: KTColor.textSecondary),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.announcements.length > 2
                  ? 2
                  : controller.announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.announcements[index];
                return KTAnnouncementCard(
                  title: item['title'],
                  description: item['description'] ?? '',
                  badgeText: item['badge_text'] ?? 'Info',
                  onTap: () {
                    KTAlertDialog.show(
                      context,
                      title: item['title'],
                      content: item['description'] ?? '',
                      confirmText: 'Tutup',
                      confirmColor: KTColor.primary,
                      showCancel: false,
                      onConfirm: () {},
                    );
                  },
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          KTSectionHeading(
            title: "Berita Terbaru",
            onPressed: () => Get.to(() => const NewsScreen()),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.news.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Belum ada berita",
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ),
              );
            }
            final count = controller.news.length > 2
                ? 2
                : controller.news.length;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = controller.news[index];
                return NewsCompactCard(
                  newsItem: item,
                  onTap: () => Get.to(() => NewsDetailScreen(newsItem: item)),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: KTColor.card,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: KTColor.textPrimary,
                letterSpacing: -0.5,
              ),
            );
          }),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.82, // More compact
            children: [
              KTButtonFitur(
                icon: Icons.people_rounded,
                label: "Pengurus",
                onTap: () => Get.to(() => const ManagementScreen()),
              ),
              KTButtonFitur(
                icon: Icons.photo_library_rounded,
                label: "Galeri",
                onTap: () => Get.to(() => const GalleryScreen()),
              ),
              KTButtonFitur(
                icon: Icons.account_balance_wallet_rounded,
                label: "Keuangan",
                onTap: () => Get.to(() => const OrganizationFinanceScreen()),
              ),
              KTButtonFitur(
                icon: Icons.event_rounded,
                label: "Event",
                onTap: () =>
                    Get.to(() => const EventScreen(showBackButton: true)),
              ),
              KTButtonFitur(
                icon: Icons.newspaper_rounded,
                label: "Berita",
                onTap: () => Get.to(() => const NewsScreen()),
              ),
              KTButtonFitur(
                icon: Icons.poll_rounded,
                label: "Polling",
                onTap: () => Get.to(() => const PollingScreen()),
              ),
              KTButtonFitur(
                icon: Icons.campaign_rounded,
                label: "Aspirasi",
                onTap: () => Get.to(() => const AllAspirationsScreen()),
              ),
              KTButtonFitur(
                icon: Icons.settings_rounded,
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
