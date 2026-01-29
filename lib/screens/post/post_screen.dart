import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _aspirationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAspirations();
  }

  void _refreshAspirations() {
    setState(() {
      _aspirationsFuture = _supabaseService.getUserAspirations();
    });
  }

  void _showAddAspirationDialog() {
    final contentController = TextEditingController();
    Get.defaultDialog(
      title: "Buat Aspirasi",
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
          try {
            final user = _supabaseService.currentUser;
            if (user == null) {
              Get.back();
              Get.snackbar("Error", "Anda harus login");
              return;
            }

            // Try to get name from metadata, fallback to email
            final authorName =
                user.userMetadata?['full_name'] ??
                user.email?.split('@')[0] ??
                "Anonymous";

            await _supabaseService.submitAspiration(
              authorName,
              contentController.text,
              userId: user.id,
            );
            Get.back();
            Get.snackbar("Sukses", "Aspirasi berhasil dikirim");
            _refreshAspirations();
          } catch (e) {
            Get.back();
            Get.snackbar("Error", "Gagal mengirim aspirasi: $e");
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshAspirations(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _aspirationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final aspirations = snapshot.data ?? [];

              if (aspirations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "belum ada aspirasi yang anda kirim, buat aspirasi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddAspirationDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Buat Aspirasi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00BA9B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 80),
                itemCount: aspirations.length,
                itemBuilder: (context, index) {
                  final item = aspirations[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: KTAspirationCard(
                      author: item['author'] ?? 'User',
                      content: item['content'] ?? '',
                      createdAt:
                          DateTime.tryParse(item['created_at']) ??
                          DateTime.now(),
                      status: item['status'], // Might be null
                      onTap: () {},
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAspirationDialog,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add),
      ),
    );
  }
}
