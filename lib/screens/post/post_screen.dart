import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_form_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_detail_screen.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  void _showAddAspirationDialog(
    BuildContext context,
    DataController controller,
  ) {
    final supabaseService = SupabaseService();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  child: AspirationFormCard(
                    isLoading: isLoading,
                    onSubmit: (title, content, category, image) async {
                      setState(() => isLoading = true);
                      try {
                        final user = supabaseService.currentUser;

                        // Ensure we have the latest profile data
                        await controller.fetchUserProfile();

                        final profile = controller.userProfile;
                        String authorName = "Anonymous";

                        if (profile['full_name'] != null &&
                            profile['full_name'].toString().isNotEmpty) {
                          authorName = profile['full_name'];
                        } else if (user?.userMetadata?['full_name'] != null) {
                          authorName = user!.userMetadata!['full_name'];
                        } else if (user?.email != null) {
                          authorName = user!.email!.split('@')[0];
                        }

                        String? imageUrl;
                        if (image != null) {
                          imageUrl = await supabaseService
                              .uploadAspirationImage(image);
                        }

                        await supabaseService.submitAspiration(
                          authorName,
                          content,
                          userId: user?.id,
                          title: title,
                          category: category,
                          imageUrl: imageUrl,
                        );

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          Get.snackbar("Sukses", "Aspirasi berhasil dikirim");
                          controller.fetchUserAspirations();
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          setState(() => isLoading = false);
                          Get.snackbar("Error", "Gagal mengirim aspirasi: $e");
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          },
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
                        onTap: () => Get.to(
                            () => AspirationDetailScreen(aspiration: item)),
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
