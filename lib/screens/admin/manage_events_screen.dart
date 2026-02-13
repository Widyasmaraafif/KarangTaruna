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

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  void _confirmDelete(int id) {
    final supabaseService = SupabaseService();
    final controller = Get.find<DataController>();

    KTAlertDialog.show(
      Get.context!,
      title: 'Hapus Event',
      content: 'Apakah Anda yakin ingin menghapus event ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await supabaseService.deleteEvent(id);
          controller.fetchEvents();
          Get.snackbar(
            'Sukses',
            'Event berhasil dihapus',
            backgroundColor: KTColor.success,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus event: $e',
            backgroundColor: KTColor.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showEventForm({Map<String, dynamic>? event}) {
    final controller = Get.find<DataController>();
    final supabaseService = SupabaseService();

    final titleController = TextEditingController(text: event?['title']);
    final descriptionController = TextEditingController(
      text: event?['description'],
    );
    final locationController = TextEditingController(text: event?['location']);
    final dateController = TextEditingController(
      text: event?['date'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(event!['date']))
          : '',
    );

    File? imageFile;
    String? imageUrl = event?['image_url'];
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
                        event == null ? 'Tambah Event' : 'Edit Event',
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
                                  'Pilih Foto Event',
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
                    labelText: 'Nama Event',
                    hintText: 'Masukkan nama event',
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: descriptionController,
                    labelText: 'Deskripsi',
                    hintText: 'Masukkan deskripsi event',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: locationController,
                    labelText: 'Lokasi',
                    hintText: 'Masukkan lokasi event',
                    prefixIcon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: dateController,
                    labelText: 'Tanggal',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dateController.text.isNotEmpty
                            ? DateTime.parse(dateController.text)
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: KTColor.primary,
                                onPrimary: Colors.white,
                                onSurface: KTColor.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => KTButton(
                      text: event == null ? 'Buat Event' : 'Simpan Perubahan',
                      isLoading: isSaving.value,
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            dateController.text.isEmpty ||
                            locationController.text.isEmpty) {
                          Get.snackbar(
                            'Peringatan',
                            'Judul, tanggal, dan lokasi wajib diisi',
                            backgroundColor: KTColor.warning,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        isSaving.value = true;

                        try {
                          if (imageFile != null) {
                            imageUrl = await supabaseService.uploadEventImage(
                              imageFile!,
                            );
                          }

                          final data = {
                            'title': titleController.text,
                            'description': descriptionController.text,
                            'location': locationController.text,
                            'date': dateController.text,
                            'image_url': imageUrl,
                            'updated_at': DateTime.now().toIso8601String(),
                          };

                          if (event == null) {
                            data['created_at'] = DateTime.now()
                                .toIso8601String();
                            await supabaseService.createEvent(data);
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Event berhasil dibuat',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          } else {
                            await supabaseService.updateEvent(
                              event['id'],
                              data,
                            );
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Event berhasil diperbarui',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          }

                          controller.fetchEvents();
                        } catch (e) {
                          isSaving.value = false;
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan event: $e',
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
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Kelola Event'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchEvents,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.isLoadingEvents.value && controller.events.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: KTColor.primary),
            );
          }

          if (controller.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada event',
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

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = controller.events[index];
              final date =
                  DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();

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
                    if (event['image_url'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          event['image_url'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 160,
                                color: KTColor.background,
                                child: const Icon(
                                  Icons.broken_image,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event['title'] ?? 'Tanpa Judul',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: KTColor.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: KTColor.textSecondary,
                                  size: 20,
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
                                          color: KTColor.textPrimary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: KTColor.textPrimary,
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
                                          Icons.delete_rounded,
                                          size: 18,
                                          color: KTColor.error,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: KTColor.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEventForm(event: event);
                                  } else if (value == 'delete') {
                                    _confirmDelete(event['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 12,
                                      color: KTColor.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event['location'] ??
                                            'Lokasi tidak ditentukan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: KTColor.textSecondary
                                              .withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
