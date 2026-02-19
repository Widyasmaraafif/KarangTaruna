import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_form_card.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class AspirationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> aspiration;

  const AspirationDetailScreen({super.key, required this.aspiration});

  @override
  Widget build(BuildContext context) {
    final author = aspiration['author'] ?? 'Anonim';
    final content = aspiration['content'] ?? '';
    final createdAt =
        DateTime.tryParse(aspiration['created_at'] ?? '') ?? DateTime.now();
    final status = aspiration['status'] ?? 'pending';
    final currentUserId = SupabaseService().currentUser?.id;
    final canManage =
        currentUserId != null && aspiration['user_id'] == currentUserId;

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Detail Aspirasi",
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
        actions: canManage
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: KTColor.textPrimary,
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: KTColor.error,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: KTColor.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: KTColor.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: KTColor.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: KTColor.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: KTColor.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedDate(createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: KTColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: KTColor.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        color = KTColor.success;
        text = 'Disetujui';
        break;
      case 'rejected':
      case 'ditolak':
        color = KTColor.error;
        text = 'Ditolak';
        break;
      case 'pending':
      default:
        color = KTColor.warning;
        text = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                    initialTitle: aspiration['title'] ?? '',
                    initialContent: aspiration['content'] ?? '',
                    initialCategory: aspiration['category'] ?? 'Umum',
                    submitLabel: "Simpan Perubahan",
                    onSubmit: (title, content, category, image) async {
                      setState(() => isLoading = true);
                      try {
                        final id = aspiration['id'] as int;
                        String? imageUrl = aspiration['image_url'];
                        if (image != null) {
                          imageUrl = await SupabaseService()
                              .uploadAspirationImage(image);
                        }
                        await SupabaseService().updateAspiration(id, {
                          'title': title,
                          'content': content,
                          'category': category,
                          'image_url': imageUrl,
                        });
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          Get.snackbar(
                            "Sukses",
                            "Aspirasi berhasil diperbarui",
                            backgroundColor: KTColor.success,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          setState(() => isLoading = false);
                          Get.snackbar(
                            "Error",
                            "Gagal memperbarui aspirasi: $e",
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Aspirasi"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus aspirasi ini? Tindakan ini tidak dapat dibatalkan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final id = aspiration['id'] as int;
                  await SupabaseService().deleteAspiration(id);
                  Get.back();
                  Get.snackbar(
                    "Sukses",
                    "Aspirasi berhasil dihapus",
                    backgroundColor: KTColor.success,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Gagal menghapus aspirasi: $e",
                    backgroundColor: KTColor.error,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                "Hapus",
                style: TextStyle(color: KTColor.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
