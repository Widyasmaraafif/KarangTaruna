import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/services/notification_service.dart';
import 'package:karang_taruna/screens/auth/register_screen.dart';
import 'package:karang_taruna/navigation_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = SupabaseService();
  final _isLoading = false.obs;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password harus diisi',
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
      await _service.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      await NotificationService.instance.refreshFcmTokenForCurrentUser();
      Get.offAll(() => const NavigationMenu());
    } on AuthException catch (e) {
      Get.snackbar(
        'Login Gagal',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.spa_rounded, size: 80, color: KTColor.primary),
                const SizedBox(height: 32),
                const Text(
                  'Selamat Datang',
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
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 14,
                    color: KTColor.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
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
                const SizedBox(height: 32),
                Obx(
                  () => KTButton(
                    text: 'Login',
                    isLoading: _isLoading.value,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: KTColor.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(
                        () => const RegisterScreen(),
                        transition: Transition.cupertino,
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: KTColor.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
