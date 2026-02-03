import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_form_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_detail_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class AllAspirationsScreen extends StatelessWidget {
  const AllAspirationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();
    final SupabaseService supabaseService = SupabaseService();

    // Refresh on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAspirations();
    });

    void showAddAspirationDialog() {
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

                          // Get author name from DataController userProfile
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
                            controller.fetchAspirations();
                            controller.fetchUserAspirations();
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            setState(() => isLoading = false);
                            Get.snackbar(
                              "Error",
                              "Gagal mengirim aspirasi: $e",
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Pojok Kampung",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddAspirationDialog,
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAspirations(),
        color: const Color(0xFF00BA9B),
        child: Obx(() {
          if (controller.isLoadingAspirations.value &&
              controller.allAspirations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BA9B)),
            );
          }

          if (controller.allAspirations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada aspirasi",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.allAspirations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = controller.allAspirations[index];
              return KTAspirationCard(
                author: item['author'] ?? 'Anonim',
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
