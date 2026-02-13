import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/navigation_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = SupabaseService();
  final _isLoading = false.obs;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua kolom harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Password tidak cocok',
        snackPosition: SnackPosition.TOP,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    _isLoading.value = true;
    try {
      final response = await _service.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      if (response.session != null) {
        // Create profile entry
        try {
          await _service.createProfile(
            userId: response.user!.id,
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
          );
        } catch (e) {
          debugPrint('Error creating profile: $e');
        }

        Get.offAll(() => const NavigationMenu());
        Get.snackbar(
          'Sukses',
          'Registrasi berhasil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: KTColor.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );
      } else {
        // Email confirmation required
        Get.back();
        Get.snackbar(
          'Registrasi Berhasil',
          'Silakan cek email Anda untuk verifikasi akun',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: KTColor.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );
      }
    } on AuthException catch (e) {
      Get.snackbar(
        'Registrasi Gagal',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: KTColor.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: KTColor.textPrimary,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar untuk bergabung dengan kami',
                  style: TextStyle(
                    fontSize: 14, 
                    color: KTColor.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                KTTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap anda',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                KTTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email anda',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                KTTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan password anda',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                KTTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi password anda',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  isPassword: true,
                ),
                const SizedBox(height: 40),
                Obx(() => KTButton(
                  text: 'Daftar',
                  isLoading: _isLoading.value,
                  onPressed: _register,
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
