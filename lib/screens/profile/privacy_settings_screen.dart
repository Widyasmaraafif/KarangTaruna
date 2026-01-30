import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Privasi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final settings = controller.privacySettings;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Visibilitas Profil'),
            _buildSwitchTile(
              title: 'Tampilkan Profil',
              subtitle: 'Izinkan orang lain melihat profil Anda',
              value: settings['showProfile'] ?? true,
              onChanged: (val) => _updateSetting(controller, 'showProfile', val),
            ),
            _buildSwitchTile(
              title: 'Tampilkan Nomor HP',
              subtitle: 'Nomor HP terlihat oleh anggota lain',
              value: settings['showPhone'] ?? false,
              onChanged: (val) => _updateSetting(controller, 'showPhone', val),
            ),
            _buildSwitchTile(
              title: 'Tampilkan Email',
              subtitle: 'Email terlihat oleh anggota lain',
              value: settings['showEmail'] ?? false,
              onChanged: (val) => _updateSetting(controller, 'showEmail', val),
            ),
            const Divider(height: 32),
            _buildSectionHeader('Interaksi'),
            _buildSwitchTile(
              title: 'Izinkan Penandaan',
              subtitle: 'Izinkan orang lain menandai Anda di foto/kegiatan',
              value: settings['allowTagging'] ?? true,
              onChanged: (val) => _updateSetting(controller, 'allowTagging', val),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Pengaturan ini membantu Anda mengontrol siapa yang dapat melihat informasi pribadi Anda di aplikasi Karang Taruna.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSetting(DataController controller, String key, bool value) {
    controller.updatePrivacySetting(key, value);
    Get.snackbar(
      'Berhasil',
      'Pengaturan privasi berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00BA9B),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00BA9B),
    );
  }
}
