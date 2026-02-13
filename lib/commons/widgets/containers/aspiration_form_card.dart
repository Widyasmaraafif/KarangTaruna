import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class AspirationFormCard extends StatefulWidget {
  final Function(String title, String content, String category, File? image)
  onSubmit;
  final bool isLoading;

  const AspirationFormCard({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<AspirationFormCard> createState() => _AspirationFormCardState();
}

class _AspirationFormCardState extends State<AspirationFormCard> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String _selectedCategory = 'Umum';
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Umum',
    'Infrastruktur',
    'Kebersihan',
    'Keamanan',
    'Sosial',
    'Lainnya',
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text,
        _contentController.text,
        _selectedCategory,
        _selectedImage,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: KTColor.primary, size: 20),
      filled: true,
      fillColor: KTColor.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KTColor.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: KTColor.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: KTColor.textGrey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KTColor.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 14, color: KTColor.textPrimary),
              decoration: _inputDecoration(
                label: "Judul Aspirasi",
                hint: "Contoh: Jalan Berlubang di RT 01",
                icon: Icons.title_rounded,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              style: const TextStyle(fontSize: 14, color: KTColor.textPrimary),
              decoration: _inputDecoration(
                label: "Kategori",
                hint: "",
                icon: Icons.category_rounded,
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Content Field
            TextFormField(
              controller: _contentController,
              style: const TextStyle(fontSize: 14, color: KTColor.textPrimary),
              decoration: _inputDecoration(
                label: "Isi Aspirasi",
                hint: "Jelaskan detail aspirasi Anda...",
                icon: Icons.description_rounded,
              ).copyWith(alignLabelWithHint: true),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Isi aspirasi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Image Picker
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: KTColor.error, size: 20),
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                label: const Text("Tambah Foto (Opsional)"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KTColor.primary,
                  side: BorderSide(color: KTColor.primary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: KTColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Kirim Aspirasi",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

