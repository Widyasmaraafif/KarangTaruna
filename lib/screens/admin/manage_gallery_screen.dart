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

class ManageGalleryScreen extends StatefulWidget {
  const ManageGalleryScreen({super.key});

  @override
  State<ManageGalleryScreen> createState() => _ManageGalleryScreenState();
}

class _ManageGalleryScreenState extends State<ManageGalleryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataController _dataController = Get.find<DataController>();
  final RxList<Map<String, dynamic>> _galleryList =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;
      final gallery = await _supabaseService.getGallery();
      _galleryList.assignAll(gallery);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data galeri: $e');
    } finally {
      if (!silent) _isLoading.value = false;
    }
  }

  void _deleteGalleryItem(int id) {
    KTAlertDialog.show(
      context,
      title: 'Hapus Foto',
      content: 'Apakah Anda yakin ingin menghapus foto ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await _supabaseService.deleteGalleryItem(id);
          await _fetchGallery();
          _dataController.fetchGallery(); // Update global state
          Get.snackbar(
            'Sukses',
            'Foto berhasil dihapus',
            backgroundColor: KTColor.success,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus foto: $e',
            backgroundColor: KTColor.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showAddForm() {
    final captionController = TextEditingController();
    File? imageFile;
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
                      const Text(
                        'Tambah Foto Galeri',
                        style: TextStyle(
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
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 200,
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
                            : null,
                      ),
                      child: imageFile == null
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
                                  'Pilih Foto',
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
                    controller: captionController,
                    labelText: 'Keterangan',
                    hintText: 'Masukkan keterangan foto (opsional)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => KTButton(
                      text: 'Simpan',
                      isLoading: isSaving.value,
                      onPressed: () async {
                        if (imageFile == null) {
                          Get.snackbar(
                            'Peringatan',
                            'Silakan pilih foto terlebih dahulu',
                            backgroundColor: KTColor.warning,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        isSaving.value = true;

                        try {
                          // Upload image
                          final imageUrl = await _supabaseService
                              .uploadGalleryImage(imageFile!);

                          final data = {
                            'image_url': imageUrl,
                            'caption': captionController.text,
                            'created_at': DateTime.now().toIso8601String(),
                          };

                          await _supabaseService.createGalleryItem(data);

                          Get.back(); // Close bottom sheet

                          Get.snackbar(
                            'Sukses',
                            'Foto berhasil ditambahkan',
                            backgroundColor: KTColor.success,
                            colorText: Colors.white,
                          );

                          await _fetchGallery(silent: true);
                          _dataController.fetchGallery();
                        } catch (e) {
                          isSaving.value = false;
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan foto: $e',
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
          "Kelola Galeri",
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
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: KTColor.primary),
          );
        }

        if (_galleryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: KTColor.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada foto di galeri',
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
          onRefresh: () => _fetchGallery(silent: true),
          color: KTColor.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _galleryList.length,
            itemBuilder: (context, index) {
              final item = _galleryList[index];
              final date =
                  DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              item['image_url'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: KTColor.background,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: KTColor.border,
                                    ),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['caption'] != null &&
                                          item['caption'].toString().isNotEmpty
                                      ? item['caption']
                                      : 'Tanpa Keterangan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: KTColor.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 10,
                                      color: KTColor.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(date),
                                      style: TextStyle(
                                        color: KTColor.textSecondary.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _deleteGalleryItem(item['id']),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              size: 16,
                              color: KTColor.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        backgroundColor: KTColor.primary,
        elevation: 4,
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
      ),
    );
  }
}
