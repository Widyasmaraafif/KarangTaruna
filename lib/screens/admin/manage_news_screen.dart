import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataController _dataController = Get.find<DataController>();
  final RxList<Map<String, dynamic>> _newsList = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;
      final news = await _supabaseService.getNews();
      _newsList.assignAll(news);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat berita: $e');
    } finally {
      if (!silent) _isLoading.value = false;
    }
  }

  void _deleteNews(int id) {
    KTAlertDialog.show(
      context,
      title: 'Hapus Berita',
      content: 'Apakah Anda yakin ingin menghapus berita ini?',
      confirmText: 'Hapus',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          await _supabaseService.deleteNews(id);
          await _fetchNews();
          _dataController.fetchNews(); // Update global state
          Get.snackbar(
            'Sukses',
            'Berita berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus berita: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showNewsForm({Map<String, dynamic>? news}) {
    final titleController = TextEditingController(text: news?['title']);
    final contentController = TextEditingController(text: news?['content']);
    final authorController = TextEditingController(
      text:
          news?['author'] ??
          _dataController.userProfile['full_name'] ??
          'Admin',
    );

    File? imageFile;
    String? imageUrl = news?['image_url'];
    bool isSaving = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    news == null ? 'Tambah Berita' : 'Edit Berita',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BA9B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 600,
                        imageQuality: 80,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: imageFile != null
                            ? DecorationImage(
                                image: FileImage(imageFile!),
                                fit: BoxFit.cover,
                              )
                            : (imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child: imageFile == null && imageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah Foto',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Berita',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      labelText: 'Penulis',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (titleController.text.isEmpty ||
                                  contentController.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Judul dan konten wajib diisi',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setState(() => isSaving = true);

                              try {
                                // Upload image if selected
                                if (imageFile != null) {
                                  try {
                                    imageUrl = await _supabaseService
                                        .uploadNewsImage(imageFile!);
                                  } catch (e) {
                                    setState(() => isSaving = false);
                                    Get.snackbar(
                                      'Error',
                                      'Gagal mengupload gambar: $e',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                }

                                final data = {
                                  'title': titleController.text,
                                  'content': contentController.text,
                                  'author': authorController.text,
                                  'image_url': imageUrl,
                                  'update_at': DateTime.now().toIso8601String(),
                                };

                                if (news == null) {
                                  data['created_at'] = DateTime.now()
                                      .toIso8601String();
                                  await _supabaseService.createNews(data);

                                  Get.back(); // Close bottom sheet

                                  Get.snackbar(
                                    'Sukses',
                                    'Berita berhasil ditambahkan',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  await _supabaseService.updateNews(
                                    news['id'],
                                    data,
                                  );

                                  Get.back(); // Close bottom sheet

                                  Get.snackbar(
                                    'Sukses',
                                    'Berita berhasil diperbarui',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                }

                                await _fetchNews(
                                  silent: true,
                                ); // Refresh list silently
                                _dataController
                                    .fetchNews(); // Update global state
                              } catch (e) {
                                setState(() => isSaving = false);
                                Get.snackbar(
                                  'Error',
                                  'Gagal menyimpan berita: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BA9B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(news == null ? 'Publikasi' : 'Update'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kelola Berita',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00BA9B)),
          );
        }

        if (_newsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.newspaper_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada berita',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
            final news = _newsList[index];
            final date = DateTime.parse(news['created_at']);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news['image_url'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        news['image_url'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                news['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showNewsForm(news: news);
                                } else if (value == 'delete') {
                                  _deleteNews(news['id']);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news['content'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news['author'] ?? 'Admin',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsForm(),
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
