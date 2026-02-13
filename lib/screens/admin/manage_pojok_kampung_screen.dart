import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

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
      Get.snackbar(
        'Error',
        'Gagal memuat data Pojok Kampung: $e',
        backgroundColor: KTColor.error,
        colorText: Colors.white,
      );
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
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await _supabaseService.deleteAspiration(id);
          await _fetchAspirations();
          _dataController.fetchAspirations(); // Update global state
          Get.snackbar(
            'Sukses',
            'Item berhasil dihapus',
            backgroundColor: KTColor.success,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus item: $e',
            backgroundColor: KTColor.error,
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

    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.add(selectedStatus);
    }

    File? imageFile;
    String? imageUrl = item?['image_url'];
    final isSaving = false.obs;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null
                            ? 'Tambah Pojok Kampung'
                            : 'Edit Pojok Kampung',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KTColor.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: KTColor.textSecondary,
                        ),
                      ),
                    ],
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
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: KTColor.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: KTColor.border.withValues(alpha: 0.5),
                        ),
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
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah Foto',
                                  style: TextStyle(
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: titleController,
                    labelText: 'Judul',
                    hintText: 'Masukkan judul',
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: contentController,
                    labelText: 'Konten',
                    hintText: 'Tuliskan konten atau aspirasi...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: authorController,
                    labelText: 'Penulis',
                    hintText: 'Nama penulis',
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kategori",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: KTColor.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        style: const TextStyle(
                          fontSize: 14,
                          color: KTColor.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: KTColor.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: KTColor.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: KTColor.primary,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: KTColor.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        style: const TextStyle(
                          fontSize: 14,
                          color: KTColor.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: KTColor.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: KTColor.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: KTColor.primary,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
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
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => KTButton(
                      text: item == null ? 'Simpan' : 'Update',
                      isLoading: isSaving.value,
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          Get.snackbar(
                            'Peringatan',
                            'Judul dan konten wajib diisi',
                            backgroundColor: KTColor.warning,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        isSaving.value = true;

                        try {
                          if (imageFile != null) {
                            try {
                              imageUrl = await _supabaseService
                                  .uploadAspirationImage(imageFile!);
                            } catch (e) {
                              isSaving.value = false;
                              Get.snackbar(
                                'Error',
                                'Gagal mengupload gambar: $e',
                                backgroundColor: KTColor.error,
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
                            await _supabaseService.createAspirationFull(data);
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Data berhasil ditambahkan',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          } else {
                            await _supabaseService.updateAspiration(
                              item['id'],
                              data,
                            );
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Data berhasil diperbarui',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          }

                          await _fetchAspirations(silent: true);
                          _dataController.fetchAspirations();
                        } catch (e) {
                          isSaving.value = false;
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan data: $e',
                            backgroundColor: KTColor.error,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
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
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Kelola Pojok Kampung",
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
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: KTColor.primary),
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
                  color: KTColor.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data Pojok Kampung',
                  style: TextStyle(
                    color: KTColor.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _fetchAspirations(silent: true),
          color: KTColor.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _aspirationsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = _aspirationsList[index];
              final date =
                  DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();
              final status = item['status'] ?? 'pending';

              return Container(
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
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: KTColor.background,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: KTColor.border,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildStatusBadge(status),
                                        const SizedBox(width: 8),
                                        Text(
                                          item['category'] ?? 'Umum',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: KTColor.primary.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['title'] ?? 'Tanpa Judul',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: KTColor.textPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                                child: PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: KTColor.textSecondary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_rounded,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: KTColor.error,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Hapus',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: KTColor.error,
                                            ),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['content'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: KTColor.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: KTColor.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['author'] ?? 'Admin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: KTColor.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('dd MMM yyyy').format(date),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
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
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'approved':
        color = KTColor.success;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = KTColor.error;
        label = 'Ditolak';
        break;
      default:
        color = KTColor.warning;
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
