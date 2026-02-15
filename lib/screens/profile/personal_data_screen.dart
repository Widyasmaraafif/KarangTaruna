import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final controller = Get.find<DataController>();
  final _supabaseService = SupabaseService(); // Direct instance for upload

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;
  late TextEditingController _bioController;

  String? _selectedGender;
  File? _imageFile;
  final _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = controller.userProfile;
    _nameController = TextEditingController(text: profile['full_name'] ?? '');
    _phoneController = TextEditingController(text: profile['phone'] ?? '');
    _addressController = TextEditingController(text: profile['address'] ?? '');
    _birthDateController = TextEditingController(
      text: profile['birth_date'] ?? '',
    );
    _bioController = TextEditingController(text: profile['bio'] ?? '');
    _selectedGender = profile['gender']?.toString().isNotEmpty == true
        ? profile['gender']
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Resize image
      maxHeight: 800,
      imageQuality: 70, // Compress image
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Check file size (limit to 2MB)
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 2) {
        Get.snackbar(
          'Gagal Memilih Foto',
          'Ukuran foto terlalu besar (Maksimal 2MB). Silakan pilih foto lain.',
          backgroundColor: KTColor.warning,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthDateController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

    if (picked != null) {
      setState(() {
        // Format: YYYY-MM-DD
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        String? newAvatarUrl;

        // Upload image if selected
        if (_imageFile != null) {
          try {
            newAvatarUrl = await _supabaseService.uploadAvatar(_imageFile!);
          } catch (e) {
            Get.snackbar(
              'Warning',
              'Gagal upload foto: $e. Data lain tetap disimpan.',
              backgroundColor: KTColor.warning,
              colorText: Colors.white,
            );
          }
        }

        await controller.updateProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          birthDate: _birthDateController.text.trim(),
          bio: _bioController.text.trim(),
          gender: _selectedGender,
          avatarUrl: newAvatarUrl,
        );

        Get.snackbar(
          'Sukses',
          'Data diri berhasil diperbarui',
          backgroundColor: KTColor.success,
          colorText: Colors.white,
        );

        // Reset image file selection on success
        if (mounted) {
          setState(() {
            _imageFile = null;
          });
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menyimpan perubahan: $e',
          backgroundColor: KTColor.error,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Data Diri",
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
      backgroundColor: KTColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final profile = controller.userProfile;
                      final avatarUrl =
                          profile['avatar_url'] ??
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(profile['full_name'] ?? 'User')}&background=random';

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: KTColor.shadow.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          color: Colors.white,
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: KTColor.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Role (Read Only)
              Obx(
                () => _buildReadOnlyField(
                  "Peran",
                  controller.userProfile['role'] ?? 'User',
                  Icons.verified_user_outlined,
                ),
              ),

              const SizedBox(height: 24),

              // Full Name
              KTTextField(
                controller: _nameController,
                labelText: "Nama Lengkap",
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              const SizedBox(height: 24),

              // Gender Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jenis Kelamin",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KTColor.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    style: const TextStyle(
                      fontSize: 14,
                      color: KTColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.people_outline_rounded,
                        color: KTColor.iconPrimary,
                        size: 20,
                      ),
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
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                      DropdownMenuItem(value: 'P', child: Text("Perempuan")),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Birth Date
              KTTextField(
                controller: _birthDateController,
                labelText: "Tanggal Lahir",
                prefixIcon: const Icon(Icons.calendar_today_rounded),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 24),

              // Phone
              KTTextField(
                controller: _phoneController,
                labelText: "Nomor Telepon",
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Address
              KTTextField(
                controller: _addressController,
                labelText: "Alamat",
                prefixIcon: const Icon(Icons.home_outlined),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Bio
              KTTextField(
                controller: _bioController,
                labelText: "Bio / Deskripsi Diri",
                prefixIcon: const Icon(Icons.info_outline_rounded),
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Save Button
              KTButton(
                text: "Simpan Perubahan",
                onPressed: _saveProfile,
                isLoading: _isSaving,
                icon: Icons.save_rounded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: KTColor.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: KTColor.border.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KTColor.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: KTColor.textSecondary),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: KTColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
