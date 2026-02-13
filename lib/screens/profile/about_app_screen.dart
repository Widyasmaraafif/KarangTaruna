import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppLogo(),
              const SizedBox(height: 24),
              const Text(
                'Karang Taruna',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: KTColor.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 14, color: KTColor.textSecondary),
              ),
              const SizedBox(height: 32),
              const Text(
                'Aplikasi Manajemen Digital Karang Taruna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KTColor.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Platform terintegrasi untuk memudahkan pengelolaan kegiatan, administrasi, and komunikasi anggota Karang Taruna. Mewujudkan organisasi yang lebih modern, transparan, and produktif.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: KTColor.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildFeatureList(),
              const SizedBox(height: 48),
              const Text(
                '© 2026 Karang Taruna Digital',
                style: TextStyle(fontSize: 12, color: KTColor.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dibuat dengan ❤️ untuk Pemuda Indonesia',
                style: TextStyle(fontSize: 12, color: KTColor.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: KTColor.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.diversity_3, size: 50, color: KTColor.primary),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureItem(Icons.event_note, 'Manajemen Kegiatan'),
        _buildFeatureItem(Icons.payment, 'Transparansi Iuran'),
        _buildFeatureItem(Icons.poll, 'Polling & Aspirasi'),
        _buildFeatureItem(Icons.newspaper, 'Berita & Informasi'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: KTColor.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KTColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
