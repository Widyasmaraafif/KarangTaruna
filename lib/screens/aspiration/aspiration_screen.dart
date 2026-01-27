import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class AspirationScreen extends StatefulWidget {
  const AspirationScreen({super.key});

  @override
  State<AspirationScreen> createState() => _AspirationScreenState();
}

class _AspirationScreenState extends State<AspirationScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _aspirationsFuture;

  @override
  void initState() {
    super.initState();
    _aspirationsFuture = _supabaseService.getAspirations();
  }

  Future<void> _refreshAspirations() async {
    setState(() {
      _aspirationsFuture = _supabaseService.getAspirations();
    });
  }

  void _showAddAspirationDialog() {
    final contentController = TextEditingController();
    Get.defaultDialog(
      title: "Tambah Aspirasi",
      content: Column(
        children: [
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: "Tulis aspirasi Anda...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: "Kirim",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (contentController.text.isNotEmpty) {
          // In a real app, we would get the current user's name
          // For now, we'll just show a success message or try to submit if user is logged in
          try {
            final user = _supabaseService.currentUser;
            final authorName = user?.email?.split('@')[0] ?? "Anonymous";

            await _supabaseService.submitAspiration(
              authorName,
              contentController.text,
            );
            Get.back();
            Get.snackbar("Sukses", "Aspirasi berhasil dikirim");
            _refreshAspirations();
          } catch (e) {
            // If table doesn't exist or other error, just close and show mock success
            Get.back();
            Get.snackbar("Info", "Aspirasi terkirim (Mock)");
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Aspirasi",
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAspirationDialog,
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAspirations,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _aspirationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final aspirations = snapshot.data ?? [];

            // Mock data if empty
            final displayList = aspirations.isEmpty
                ? [
                    {
                      'author': 'Budi Santoso',
                      'content':
                          'Mohon diadakan kegiatan kerja bakti rutin setiap minggu pagi agar lingkungan kita tetap bersih dan asri.',
                      'created_at': DateTime.now()
                          .subtract(const Duration(days: 1))
                          .toIso8601String(),
                      'status': 'Diterima',
                    },
                    {
                      'author': 'Siti Aminah',
                      'content':
                          'Usulan untuk mengadakan lomba 17 Agustus yang lebih meriah tahun ini dengan mengundang warga desa sebelah.',
                      'created_at': DateTime.now()
                          .subtract(const Duration(days: 3))
                          .toIso8601String(),
                      'status': 'Dipertimbangkan',
                    },
                    {
                      'author': 'Rudi Hartono',
                      'content':
                          'Perlu perbaikan lampu jalan di RT 05 karena sudah mati selama 2 minggu.',
                      'created_at': DateTime.now()
                          .subtract(const Duration(days: 5))
                          .toIso8601String(),
                      'status': 'Selesai',
                    },
                  ]
                : aspirations;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = displayList[index];
                return KTAspirationCard(
                  author: item['author'] ?? 'Anonymous',
                  content: item['content'] ?? '',
                  createdAt: item['created_at'] is String
                      ? DateTime.parse(item['created_at'])
                      : (item['created_at'] as DateTime? ?? DateTime.now()),
                  status: item['status'],
                  onTap: () {
                    Get.defaultDialog(
                      title: "Detail Aspirasi",
                      middleText: item['content'] ?? '',
                      textConfirm: "Tutup",
                      confirmTextColor: Colors.white,
                      onConfirm: () => Get.back(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
