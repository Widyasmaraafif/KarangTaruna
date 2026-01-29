import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
          backgroundColor: Colors.orange,
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
              primary: Color(0xFF00BA9B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
              backgroundColor: Colors.orange,
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
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.red,
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
        title: const Text("Data Diri"),
        backgroundColor: const Color(0xFF00BA9B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                          border: Border.all(
                            color: const Color(0xFF00BA9B),
                            width: 3,
                          ),
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
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00BA9B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
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
                  controller.userProfile['role'] ?? 'Anggota',
                ),
              ),

              const SizedBox(height: 20),

              // Full Name
              _buildTextField(
                controller: _nameController,
                label: "Nama Lengkap",
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              const SizedBox(height: 20),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Jenis Kelamin",
                  prefixIcon: const Icon(
                    Icons.people_outline,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                  DropdownMenuItem(value: 'P', child: Text("Perempuan")),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
              ),

              const SizedBox(height: 20),

              // Birth Date
              InkWell(
                onTap: () => _selectDate(context),
                child: IgnorePointer(
                  child: _buildTextField(
                    controller: _birthDateController,
                    label: "Tanggal Lahir",
                    icon: Icons.calendar_today,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: "Nomor Telepon",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // Address
              _buildTextField(
                controller: _addressController,
                label: "Alamat",
                icon: Icons.home_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // Bio
              _buildTextField(
                controller: _bioController,
                label: "Bio / Deskripsi Diri",
                icon: Icons.info_outline,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BA9B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BA9B), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
