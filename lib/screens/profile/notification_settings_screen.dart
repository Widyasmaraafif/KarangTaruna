import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final settings = controller.notificationSettings;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Metode Notifikasi'),
            _buildSwitchTile(
              title: 'Push Notifikasi',
              subtitle: 'Terima notifikasi di perangkat ini',
              value: settings['pushEnabled'] ?? true,
              onChanged: (val) =>
                  _updateSetting(controller, 'pushEnabled', val),
            ),
            _buildSwitchTile(
              title: 'Email',
              subtitle: 'Terima notifikasi via email',
              value: settings['emailEnabled'] ?? false,
              onChanged: (val) =>
                  _updateSetting(controller, 'emailEnabled', val),
            ),
            _buildSwitchTile(
              title: 'WhatsApp',
              subtitle: 'Terima notifikasi via WhatsApp',
              value: settings['waEnabled'] ?? true,
              onChanged: (val) => _updateSetting(controller, 'waEnabled', val),
            ),
            const Divider(height: 32),
            _buildSectionHeader('Jenis Notifikasi'),
            _buildSwitchTile(
              title: 'Pengingat Acara',
              subtitle: 'Notifikasi untuk acara mendatang',
              value: settings['eventReminders'] ?? true,
              onChanged: (val) =>
                  _updateSetting(controller, 'eventReminders', val),
            ),
            _buildSwitchTile(
              title: 'Berita & Pengumuman',
              subtitle: 'Update berita terbaru Karang Taruna',
              value: settings['newsUpdates'] ?? false,
              onChanged: (val) =>
                  _updateSetting(controller, 'newsUpdates', val),
            ),
          ],
        );
      }),
    );
  }

  void _updateSetting(DataController controller, String key, bool value) {
    controller.updateNotificationSetting(key, value);
    Get.snackbar(
      'Berhasil',
      'Pengaturan notifikasi berhasil diperbarui',
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
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
