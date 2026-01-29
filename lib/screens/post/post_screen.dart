import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  void _showAddAspirationDialog(
    BuildContext context,
    DataController controller,
  ) {
    final contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Buat Aspirasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  try {
                    // We need current user ID
                    final user = SupabaseService().currentUser;
                    if (user == null) {
                      Navigator.of(dialogContext).pop();
                      Get.snackbar("Error", "Anda harus login");
                      return;
                    }

                    // Try to get name from metadata, fallback to email
                    final authorName =
                        user.userMetadata?['full_name'] ??
                        user.email?.split('@')[0] ??
                        "Anonymous";

                    await controller.createAspiration(
                      authorName,
                      contentController.text,
                      user.id,
                    );

                    Navigator.of(dialogContext).pop();
                    Get.snackbar("Sukses", "Aspirasi berhasil dikirim");
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                    Get.snackbar("Error", "Gagal mengirim aspirasi: $e");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BA9B),
                foregroundColor: Colors.white,
              ),
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchUserAspirations,
          child: Obx(() {
            final aspirations = controller.userAspirations;
            final isLoading = controller.isLoadingAspirations.value;

            if (isLoading && aspirations.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

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
                        onPressed: () =>
                            _showAddAspirationDialog(context, controller),
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

            return Stack(
              children: [
                ListView.builder(
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
                        status: item['status'],
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text("Detail Aspirasi"),
                                content: Text(item['content'] ?? ''),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Konfirmasi hapus
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Hapus Aspirasi"),
                                          content: const Text(
                                            "Apakah Anda yakin ingin menghapus aspirasi ini?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                "Batal",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Close confirm dialog
                                                Navigator.of(
                                                  dialogContext,
                                                ).pop(); // Close detail dialog
                                                try {
                                                  await controller
                                                      .deleteAspiration(
                                                        item['id'],
                                                      );
                                                  Get.snackbar(
                                                    "Sukses",
                                                    "Aspirasi berhasil dihapus",
                                                  );
                                                } catch (e) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Gagal menghapus: $e",
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                "Hapus",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: const Text("Tutup"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () =>
                        _showAddAspirationDialog(context, controller),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00BA9B),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
