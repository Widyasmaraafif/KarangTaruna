import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/admin/manage_account_transactions_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

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
      final isSaving = false.obs;

      Get.bottomSheet(
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          account == null
                              ? 'Tambah Akun Keuangan'
                              : 'Edit Akun Keuangan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: KTColor.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: KTColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    KTTextField(
                      controller: nameController,
                      labelText: 'Nama Akun',
                      hintText: 'Contoh: Kas Organisasi',
                    ),
                    const SizedBox(height: 16),
                    KTTextField(
                      controller: descriptionController,
                      labelText: 'Deskripsi',
                      hintText: 'Deskripsi singkat akun',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    KTTextField(
                      controller: iconController,
                      labelText: 'Nama Icon (Material Icons)',
                      hintText: 'Contoh: account_balance',
                      prefixIcon: const Icon(Icons.emoji_symbols_rounded),
                    ),
                    const SizedBox(height: 16),
                    KTTextField(
                      controller: colorController,
                      labelText: 'Warna (Hex)',
                      hintText: 'Contoh: 0xFF00BA9B',
                      prefixIcon: const Icon(Icons.palette_rounded),
                    ),
                    const SizedBox(height: 32),
                    Obx(
                      () => KTButton(
                        text: account == null
                            ? 'Tambah Akun'
                            : 'Simpan Perubahan',
                        isLoading: isSaving.value,
                        onPressed: () async {
                          if (nameController.text.isEmpty) {
                            Get.snackbar(
                              'Peringatan',
                              'Nama akun wajib diisi',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: KTColor.warning,
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                              ),
                            );
                            return;
                          }

                          isSaving.value = true;
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
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Data berhasil disimpan',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                              ),
                            );
                          } catch (e) {
                            isSaving.value = false;
                            Get.snackbar(
                              'Error',
                              'Gagal menyimpan data: $e',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: KTColor.error,
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
        isScrollControlled: true,
      );
    }

    void confirmDelete(int id) {
      KTAlertDialog.show(
        Get.context!,
        title: 'Hapus Akun',
        content:
            'Apakah Anda yakin ingin menghapus akun ini? Semua transaksi terkait juga akan terhapus.',
        confirmText: 'Hapus',
        confirmColor: KTColor.error,
        onConfirm: () async {
          try {
            await supabaseService.deleteFinanceAccount(id);
            await controller.fetchFinanceAccounts();
            Get.snackbar(
              'Sukses',
              'Akun berhasil dihapus',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: KTColor.success,
              colorText: Colors.white,
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              'Gagal menghapus akun: $e',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: KTColor.error,
              colorText: Colors.white,
              icon: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
            );
          }
        },
      );
    }

    final Map<String, IconData> iconMap = {
      'account_balance': Icons.account_balance,
      'sports_soccer': Icons.sports_soccer,
      'people': Icons.people,
      'money': Icons.attach_money,
      'default': Icons.account_balance_wallet,
    };

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Kelola Akun Keuangan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchFinanceAccounts,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.isLoadingFinanceAccounts.value &&
              controller.financeAccounts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: KTColor.primary),
            );
          }

          if (controller.financeAccounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada akun keuangan',
                    style: TextStyle(
                      color: KTColor.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.financeAccounts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final account = controller.financeAccounts[index];
              final iconName = account['icon'] ?? 'default';
              final colorHex = account['color'] ?? '0xFF00BA9B';
              final color = Color(int.parse(colorHex));
              final icon = iconMap[iconName] ?? iconMap['default']!;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: KTColor.border.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KTColor.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  title: Text(
                    account['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: KTColor.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  subtitle: Text(
                    account['description'] ?? 'Tidak ada deskripsi',
                    style: TextStyle(
                      fontSize: 12,
                      color: KTColor.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: KTColor.primary,
                          size: 20,
                        ),
                        onPressed: () => showAccountDialog(account: account),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: KTColor.error,
                          size: 20,
                        ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAccountDialog(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
