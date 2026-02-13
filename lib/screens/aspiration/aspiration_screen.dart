import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_form_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/aspiration/aspiration_detail_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class AspirationScreen extends StatefulWidget {
  const AspirationScreen({super.key});

  @override
  State<AspirationScreen> createState() => _AspirationScreenState();
}

class _AspirationScreenState extends State<AspirationScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataController _dataController = Get.find<DataController>();
  late Future<List<Map<String, dynamic>>> _aspirationsFuture;

  @override
  void initState() {
    super.initState();
    _aspirationsFuture = _supabaseService.getUserAspirations();
  }

  Future<void> _refreshAspirations() async {
    setState(() {
      _aspirationsFuture = _supabaseService.getUserAspirations();
    });
  }

  void _showAddAspirationDialog() {
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
                        final user = _supabaseService.currentUser;

                        // Ensure we have the latest profile data
                        await _dataController.fetchUserProfile();

                        final profile = _dataController.userProfile;
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
                          imageUrl = await _supabaseService
                              .uploadAspirationImage(image);
                        }

                        await _supabaseService.submitAspiration(
                          authorName,
                          content,
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
                          _refreshAspirations();
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
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Aspirasi Saya",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAspirationDialog,
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAspirations,
        color: KTColor.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _aspirationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: KTColor.primary),
              );
            }

            final aspirations = snapshot.data ?? [];

            if (aspirations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: KTColor.border,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada aspirasi",
                      style: TextStyle(
                        fontSize: 16,
                        color: KTColor.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Jadilah yang pertama menyampaikan aspirasi!",
                      style: TextStyle(fontSize: 14, color: KTColor.textGrey),
                    ),
                  ],
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
                  author: item['author'] ?? 'Anonymous',
                  content: item['content'] ?? '',
                  createdAt: item['created_at'] is String
                      ? DateTime.parse(item['created_at'])
                      : (item['created_at'] as DateTime? ?? DateTime.now()),
                  status: item['status'],
                  onTap: () =>
                      Get.to(() => AspirationDetailScreen(aspiration: item)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
