import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BA9B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Aplikasi Manajemen Digital Karang Taruna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Platform terintegrasi untuk memudahkan pengelolaan kegiatan, administrasi, dan komunikasi anggota Karang Taruna. Mewujudkan organisasi yang lebih modern, transparan, dan produktif.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildFeatureList(),
              const SizedBox(height: 48),
              const Text(
                '© 2026 Karang Taruna Digital',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dibuat dengan ❤️ untuk Pemuda Indonesia',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
        color: const Color(0xFF00BA9B).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.diversity_3, size: 50, color: Color(0xFF00BA9B)),
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
          Icon(icon, size: 20, color: const Color(0xFF00BA9B)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
