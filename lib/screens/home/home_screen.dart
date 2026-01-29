import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/buttons/button_fitur.dart';
import 'package:karang_taruna/commons/widgets/containers/announcement_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/banner.dart';
import 'package:karang_taruna/commons/widgets/containers/pooling_card.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';
import 'package:karang_taruna/commons/widgets/texts/section_heading.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_screen.dart';
import 'package:karang_taruna/screens/event/event_screen.dart';
import 'package:karang_taruna/screens/finance/finance_screen.dart';
import 'package:karang_taruna/screens/gallery/gallery_screen.dart';
import 'package:karang_taruna/screens/management/management_screen.dart';
import 'package:karang_taruna/screens/news/news_screen.dart';
import 'package:karang_taruna/screens/polling/polling_screen.dart';
import 'package:karang_taruna/screens/settings/settings_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              HeaderHome(),
              NewsHome(),
              AnnouncementHome(),
              PojokKampungHome(),
              PoolingHome(),
            ],
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
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(title: "Pooling", onPressed: () {}),
          SizedBox(height: 10),
          // TODO: Implement Pooling dynamically later
          KTPollingCard(
            question: "Kegiatan apa yang kamu pilih minggu ini?",
            options: const [
              {'id': 1, 'option_text': "Kerja bakti lingkungan", 'votes': 40},
              {'id': 2, 'option_text': "Pelatihan keterampilan", 'votes': 25},
              {'id': 3, 'option_text': "Lomba olahraga", 'votes': 35},
            ],
            totalVotes: 100,
            onVote: (id, label) {
              // TODO: logika ketika user memilih salah satu opsi
            },
          ),
        ],
      ),
    );
  }
}

class PojokKampungHome extends StatefulWidget {
  const PojokKampungHome({super.key});

  @override
  State<PojokKampungHome> createState() => _PojokKampungHomeState();
}

class _PojokKampungHomeState extends State<PojokKampungHome> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _aspirationsFuture;

  @override
  void initState() {
    super.initState();
    _aspirationsFuture = _supabaseService.getAspirations();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(title: "Pojok Kampung", onPressed: () {}),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _aspirationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (snapshot.hasError) {
                return Text('Error loading aspirations');
              }

              final aspirations = snapshot.data ?? [];

              if (aspirations.isEmpty) {
                return const Text(
                  'Belum ada aspirasi',
                  style: TextStyle(color: Colors.white),
                );
              }

              return Column(
                children: [
                  ...aspirations
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: KTAspirationCard(
                            author: item['author'],
                            content: item['content'],
                            createdAt: DateTime.parse(item['created_at']),
                            status: item['status'],
                            onTap: () {},
                          ),
                        ),
                      ),
                  KTAspirationBanner(onTap: () {}),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnnouncementHome extends StatefulWidget {
  const AnnouncementHome({super.key});

  @override
  State<AnnouncementHome> createState() => _AnnouncementHomeState();
}

class _AnnouncementHomeState extends State<AnnouncementHome> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _supabaseService.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(title: "Pengumuman Terbaru", onPressed: () {}),
          SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _announcementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final announcements = snapshot.data ?? [];

              if (announcements.isEmpty) {
                return const Text(
                  'Tidak ada pengumuman',
                  style: TextStyle(color: Colors.white),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = announcements[index];
                  return KTAnnouncementCard(
                    title: item['title'],
                    description: item['description'] ?? '',
                    badgeText: item['badge_text'] ?? 'Info',
                    onTap: () {},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class NewsHome extends StatefulWidget {
  const NewsHome({super.key});

  @override
  State<NewsHome> createState() => _NewsHomeState();
}

class _NewsHomeState extends State<NewsHome> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _supabaseService.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(title: "Berita Terbaru", onPressed: () {}),
          SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final newsList = snapshot.data ?? [];

              if (newsList.isEmpty) {
                return const Text(
                  'Tidak ada berita',
                  style: TextStyle(color: Colors.white),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 9 / 11,
                ),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final item = newsList[index];
                  return KTPostContainer(
                    imageUrl:
                        item['image_url'] ?? "https://picsum.photos/400/300",
                    title: item['title'],
                    author: item['author'] ?? 'Admin',
                    createdAt: DateTime.parse(item['created_at']),
                    content: item['content'] ?? '',
                    category: item['category'] ?? 'News',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 20),
      decoration: BoxDecoration(
        color: Color(0xff79CDB0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Welcome Back!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
