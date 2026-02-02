import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class ManagePojokKampungScreen extends StatefulWidget {
  const ManagePojokKampungScreen({super.key});

  @override
  State<ManagePojokKampungScreen> createState() =>
      _ManagePojokKampungScreenState();
}

class _ManagePojokKampungScreenState extends State<ManagePojokKampungScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataController _dataController = Get.find<DataController>();
  final RxList<Map<String, dynamic>> _aspirationsList =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchAspirations();
  }

  Future<void> _fetchAspirations({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;
      final aspirations = await _supabaseService.getAspirations();
      _aspirationsList.assignAll(aspirations);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data Pojok Kampung: $e');
    } finally {
      if (!silent) _isLoading.value = false;
    }
  }

  void _deleteAspiration(int id) {
    KTAlertDialog.show(
      context,
      title: 'Hapus Item',
      content: 'Apakah Anda yakin ingin menghapus item ini?',
      confirmText: 'Hapus',
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          await _supabaseService.deleteAspiration(id);
          await _fetchAspirations();
          _dataController.fetchAspirations(); // Update global state
          Get.snackbar(
            'Sukses',
            'Item berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus item: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showForm({Map<String, dynamic>? item}) {
    final titleController = TextEditingController(text: item?['title']);
    final contentController = TextEditingController(text: item?['content']);
    final authorController = TextEditingController(
      text:
          item?['author'] ??
          _dataController.userProfile['full_name'] ??
          'Admin',
    );
    final List<String> categories = [
      'Umum',
      'Aspirasi',
      'Berita Warga',
      'Kegiatan',
      'Lainnya',
    ];
    String selectedCategory = item?['category'] ?? 'Umum';
    // Ensure selected category is in the list, if not add it temporarily or fallback
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

    String selectedStatus = item?['status'] ?? 'pending';
    final List<String> statusOptions = ['pending', 'approved', 'rejected'];
    final Map<String, String> statusLabels = {
      'pending': 'Menunggu',
      'approved': 'Disetujui',
      'rejected': 'Ditolak',
    };

    // Ensure selected status is in the list to avoid DropdownButton error
    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.add(selectedStatus);
    }

    File? imageFile;
    String? imageUrl = item?['image_url'];
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
                    item == null
                        ? 'Tambah Pojok Kampung'
                        : 'Edit Pojok Kampung',
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
                      labelText: 'Judul',
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(statusLabels[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
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
                                        .uploadAspirationImage(imageFile!);
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
                                  'category': selectedCategory,
                                  'status': selectedStatus,
                                  'image_url': imageUrl,
                                };

                                if (item == null) {
                                  data['created_at'] = DateTime.now()
                                      .toIso8601String();
                                  await _supabaseService.createAspirationFull(
                                    data,
                                  );

                                  Get.back(); // Close bottom sheet

                                  Get.snackbar(
                                    'Sukses',
                                    'Data berhasil ditambahkan',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  await _supabaseService.updateAspiration(
                                    item['id'],
                                    data,
                                  );

                                  Get.back(); // Close bottom sheet

                                  Get.snackbar(
                                    'Sukses',
                                    'Data berhasil diperbarui',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                }

                                await _fetchAspirations(
                                  silent: true,
                                ); // Refresh list silently
                                _dataController
                                    .fetchAspirations(); // Update global state
                              } catch (e) {
                                setState(() => isSaving = false);
                                Get.snackbar(
                                  'Error',
                                  'Gagal menyimpan data: $e',
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
                          : Text(item == null ? 'Simpan' : 'Update'),
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
          'Kelola Pojok Kampung',
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

        if (_aspirationsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data Pojok Kampung',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _aspirationsList.length,
          itemBuilder: (context, index) {
            final item = _aspirationsList[index];
            final date =
                DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();

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
                  if (item['image_url'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        item['image_url'],
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
                                item['title'] ?? 'Tanpa Judul',
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
                                  _showForm(item: item);
                                } else if (value == 'delete') {
                                  _deleteAspiration(item['id']);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['content'] ?? '',
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
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item['author'] ?? 'Admin',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.category_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item['category'] ?? 'Umum',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
