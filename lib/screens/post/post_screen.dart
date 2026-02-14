import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
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
                          Get.snackbar(
                            "Sukses",
                            "Aspirasi berhasil dikirim",
                            backgroundColor: KTColor.success,
                            colorText: Colors.white,
                          );
                          controller.fetchUserAspirations();
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          setState(() => isLoading = false);
                          Get.snackbar(
                            "Error",
                            "Gagal mengirim aspirasi: $e",
                            backgroundColor: KTColor.error,
                            colorText: Colors.white,
                          );
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
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Aspirasi Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAspirationDialog(context, controller),
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchUserAspirations,
        color: KTColor.primary,
        child: Obx(() {
          final aspirations = controller.userAspirations;
          final isLoading = controller.isLoadingAspirations.value;

          if (isLoading && aspirations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: KTColor.primary),
            );
          }

          if (aspirations.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: KTColor.border,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Belum ada aspirasi yang Anda kirim",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: KTColor.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: KTButton(
                        text: "Buat Aspirasi",
                        onPressed: () =>
                            _showAddAspirationDialog(context, controller),
                        icon: Icons.add_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: aspirations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = aspirations[index];
              return KTAspirationCard(
                author: item['author'] ?? 'User',
                content: item['content'] ?? '',
                createdAt:
                    DateTime.tryParse(item['created_at']) ?? DateTime.now(),
                status: item['status'],
                onTap: () =>
                    Get.to(() => AspirationDetailScreen(aspiration: item)),
              );
            },
          );
        }),
      ),
    );
  }
}
