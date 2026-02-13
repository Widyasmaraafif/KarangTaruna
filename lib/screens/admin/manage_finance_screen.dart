import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManageFinanceScreen extends StatefulWidget {
  const ManageFinanceScreen({super.key});

  @override
  State<ManageFinanceScreen> createState() => _ManageFinanceScreenState();
}

class _ManageFinanceScreenState extends State<ManageFinanceScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final DataController _dataController = Get.find<DataController>();
  final RxList<Map<String, dynamic>> _bills = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _users = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _isLoading.value = true;
      // Fetch bills and users in parallel
      final results = await Future.wait([
        _supabaseService.getAllBills(),
        _supabaseService.getAllProfiles(),
      ]);

      _bills.assignAll(results[0] as List<Map<String, dynamic>>);
      _users.assignAll(results[1] as List<Map<String, dynamic>>);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data keuangan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteBill(int id) async {
    KTAlertDialog.show(
      context,
      title: 'Hapus Tagihan',
      content: 'Apakah Anda yakin ingin menghapus tagihan ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await _supabaseService.deleteBill(id);
          await _fetchData();
          _dataController.fetchBills(); // Update global state
          Get.snackbar(
            'Sukses',
            'Tagihan berhasil dihapus',
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
            'Gagal menghapus tagihan: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KTColor.error,
            colorText: Colors.white,
            icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          );
        }
      },
    );
  }

  void _showBillForm({Map<String, dynamic>? bill}) {
    final titleController = TextEditingController(text: bill?['title']);
    final amountController = TextEditingController(
      text: bill != null ? bill['amount'].toString() : '',
    );
    final descriptionController = TextEditingController(
      text: bill?['description'],
    );
    final dueDateController = TextEditingController(
      text: bill != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(bill['due_date']))
          : '',
    );

    String? selectedUserId = bill?['user_id'];
    String? selectedStatus = (bill?['is_paid'] == true) ? 'paid' : 'pending';
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
                        bill == null ? 'Buat Tagihan Baru' : 'Edit Tagihan',
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
                  const Text(
                    "Anggota",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KTColor.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedUserId,
                    style: const TextStyle(
                      fontSize: 14,
                      color: KTColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: KTColor.iconPrimary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: KTColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: KTColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: KTColor.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user['id'],
                        child: Text(user['full_name'] ?? 'No Name'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUserId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: titleController,
                    labelText: 'Judul Tagihan',
                    hintText: 'Masukkan judul tagihan',
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: amountController,
                    labelText: 'Jumlah',
                    hintText: 'Masukkan jumlah (Rp)',
                    prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: dueDateController,
                    readOnly: true,
                    labelText: 'Jatuh Tempo',
                    hintText: 'Pilih tanggal jatuh tempo',
                    prefixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        dueDateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Status Pembayaran",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KTColor.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    style: const TextStyle(
                      fontSize: 14,
                      color: KTColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: KTColor.iconPrimary,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: KTColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: KTColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: KTColor.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Belum Lunas'),
                      ),
                      DropdownMenuItem(value: 'paid', child: Text('Lunas')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: descriptionController,
                    labelText: 'Keterangan',
                    hintText: 'Masukkan keterangan (opsional)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => KTButton(
                      text: bill == null ? 'Simpan' : 'Update',
                      isLoading: isSaving.value,
                      onPressed: () async {
                        if (selectedUserId == null ||
                            titleController.text.isEmpty ||
                            amountController.text.isEmpty ||
                            dueDateController.text.isEmpty) {
                          Get.snackbar(
                            'Peringatan',
                            'Mohon lengkapi data wajib',
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
                            'user_id': selectedUserId,
                            'title': titleController.text,
                            'amount': int.tryParse(amountController.text) ?? 0,
                            'due_date': dueDateController.text,
                            'is_paid': selectedStatus == 'paid',
                            'description': descriptionController.text,
                            'updated_at': DateTime.now().toIso8601String(),
                          };

                          if (bill == null) {
                            data['created_at'] = DateTime.now()
                                .toIso8601String();
                            await _supabaseService.createBill(data);
                            Get.back(); // Close bottom sheet
                            Get.snackbar(
                              'Sukses',
                              'Tagihan berhasil dibuat',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                              ),
                            );
                          } else {
                            await _supabaseService.updateBill(bill['id'], data);
                            Get.back(); // Close bottom sheet
                            Get.snackbar(
                              'Sukses',
                              'Tagihan berhasil diperbarui',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                              ),
                            );
                          }

                          _fetchData(); // Refresh list
                          _dataController.fetchBills(); // Update global state
                        } catch (e) {
                          isSaving.value = false;
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan tagihan: $e',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Kelola Keuangan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: KTColor.primary),
          );
        }

        if (_bills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: KTColor.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data keuangan',
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

        return RefreshIndicator(
          onRefresh: _fetchData,
          color: KTColor.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _bills.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bill = _bills[index];
              final isPaid = bill['is_paid'] == true;
              final dueDate = DateTime.parse(bill['due_date']);
              final amount = NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(bill['amount']);

              // Handle join data if available (Supabase returns related data in nested map)
              final memberName =
                  bill['profiles']?['full_name'] ?? 'Unknown User';

              return Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bill['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: KTColor.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? KTColor.success.withValues(alpha: 0.1)
                                      : KTColor.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isPaid ? 'LUNAS' : 'BELUM LUNAS',
                                  style: TextStyle(
                                    color: isPaid
                                        ? KTColor.success
                                        : KTColor.warning,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: KTColor.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: KTColor.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  memberName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: KTColor.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: KTColor.textSecondary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 20,
                                color: KTColor.textPrimary,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: KTColor.error,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: KTColor.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showBillForm(bill: bill);
                        } else if (value == 'delete') {
                          _deleteBill(bill['id']);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBillForm(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
