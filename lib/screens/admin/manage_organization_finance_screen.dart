import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/admin/manage_account_transactions_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';

class ManageOrganizationFinanceScreen extends StatelessWidget {
  const ManageOrganizationFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();
    final SupabaseService supabaseService = SupabaseService();

    void showAccountDialog({Map<String, dynamic>? account}) {
      final nameController = TextEditingController(text: account?['name']);
      final descriptionController = TextEditingController(
        text: account?['description'],
      );
      final iconController = TextEditingController(
        text: account?['icon'] ?? 'account_balance_wallet',
      );
      final colorController = TextEditingController(
        text: account?['color'] ?? '0xFF00BA9B',
      );

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account == null
                      ? 'Tambah Akun Keuangan'
                      : 'Edit Akun Keuangan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                KTTextField(
                  controller: nameController,
                  labelText: 'Nama Akun',
                  hintText: 'Contoh: Kas Organisasi',
                ),
                const SizedBox(height: 12),
                KTTextField(
                  controller: descriptionController,
                  labelText: 'Deskripsi',
                  hintText: 'Deskripsi singkat akun',
                ),
                const SizedBox(height: 12),
                KTTextField(
                  controller: iconController,
                  labelText: 'Nama Icon (Material Icons)',
                  hintText: 'Contoh: account_balance',
                ),
                const SizedBox(height: 12),
                KTTextField(
                  controller: colorController,
                  labelText: 'Warna (Hex)',
                  hintText: 'Contoh: 0xFF00BA9B',
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    KTButton(
                      text: 'Simpan',
                      onPressed: () async {
                        if (nameController.text.isEmpty) {
                          Get.snackbar('Error', 'Nama akun wajib diisi');
                          return;
                        }

                        try {
                          final data = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            'icon': iconController.text,
                            'color': colorController.text,
                          };

                          if (account == null) {
                            await supabaseService.addFinanceAccount(data);
                          } else {
                            await supabaseService.updateFinanceAccount(
                              account['id'],
                              data,
                            );
                          }

                          await controller.fetchFinanceAccounts();
                          Navigator.of(context).pop();
                          Get.snackbar('Sukses', 'Data berhasil disimpan');
                        } catch (e) {
                          Get.snackbar('Error', 'Gagal menyimpan data: $e');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    void confirmDelete(int id) {
      Get.defaultDialog(
        title: 'Hapus Akun',
        middleText:
            'Apakah Anda yakin ingin menghapus akun ini? Semua transaksi terkait juga akan terhapus.',
        textConfirm: 'Hapus',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        onConfirm: () async {
          try {
            await supabaseService.deleteFinanceAccount(id);
            await controller.fetchFinanceAccounts();
            Get.back();
            Get.snackbar('Sukses', 'Akun berhasil dihapus');
          } catch (e) {
            Get.snackbar('Error', 'Gagal menghapus akun: $e');
          }
        },
      );
    }

    // Map string icon names to IconData (simplified subset for preview)
    final Map<String, IconData> iconMap = {
      'account_balance': Icons.account_balance,
      'sports_soccer': Icons.sports_soccer,
      'people': Icons.people,
      'money': Icons.attach_money,
      'default': Icons.account_balance_wallet,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Keuangan Organisasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingFinanceAccounts.value &&
            controller.financeAccounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.financeAccounts.isEmpty) {
          return const Center(child: Text("Belum ada akun keuangan"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.financeAccounts.length,
          itemBuilder: (context, index) {
            final account = controller.financeAccounts[index];
            final iconName = account['icon'] ?? 'default';
            final colorHex = account['color'] ?? '0xFF00BA9B';
            final color = Color(int.parse(colorHex));
            final icon = iconMap[iconName] ?? iconMap['default']!;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                title: Text(
                  account['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(account['description'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showAccountDialog(account: account),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(account['id']),
                    ),
                  ],
                ),
                onTap: () {
                  Get.to(
                    () => ManageAccountTransactionsScreen(account: account),
                  );
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAccountDialog(),
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add),
      ),
    );
  }
}
