import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';

class ManageAccountTransactionsScreen extends StatefulWidget {
  final Map<String, dynamic> account;

  const ManageAccountTransactionsScreen({super.key, required this.account});

  @override
  State<ManageAccountTransactionsScreen> createState() =>
      _ManageAccountTransactionsScreenState();
}

class _ManageAccountTransactionsScreenState
    extends State<ManageAccountTransactionsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final RxList<Map<String, dynamic>> _transactions =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  final RxBool _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    _isLoading.value = true;
    try {
      final data = await _supabaseService.getFinanceTransactions(
        widget.account['id'],
      );
      _transactions.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat transaksi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _showTransactionDialog({String type = 'income'}) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == 'income'
                        ? 'Tambah Pemasukan'
                        : 'Tambah Pengeluaran',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KTColor.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: KTColor.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              KTTextField(
                controller: titleController,
                labelText: 'Judul Transaksi',
                hintText: 'Contoh: Iuran Bulanan / Beli Peralatan',
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              const SizedBox(height: 16),
              KTTextField(
                controller: amountController,
                labelText: 'Nominal (Rp)',
                hintText: 'Contoh: 500000',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              const SizedBox(height: 16),
              KTTextField(
                controller: descriptionController,
                labelText: 'Keterangan (Opsional)',
                hintText: 'Detail tambahan...',
                maxLines: 2,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tanggal Transaksi",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: KTColor.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: KTColor.primary,
                              onPrimary: Colors.white,
                              onSurface: KTColor.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: KTColor.border.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: KTColor.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                            'id_ID',
                          ).format(selectedDate.value),
                          style: const TextStyle(
                            color: KTColor.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: KTColor.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => KTButton(
                  text: 'Simpan',
                  isLoading: _isSaving.value,
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      Get.snackbar(
                        'Peringatan',
                        'Judul dan Nominal wajib diisi',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: KTColor.warning,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    _isSaving.value = true;
                    try {
                      final amount = int.tryParse(amountController.text) ?? 0;

                      final data = {
                        'account_id': widget.account['id'],
                        'type': type,
                        'amount': amount,
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'transaction_date': selectedDate.value
                            .toIso8601String(),
                      };

                      await _supabaseService.addFinanceTransaction(data);
                      await _fetchTransactions();
                      Get.back();
                      Get.snackbar(
                        'Sukses',
                        'Transaksi berhasil disimpan',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: KTColor.success,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Gagal menyimpan transaksi: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: KTColor.error,
                        colorText: Colors.white,
                      );
                    } finally {
                      _isSaving.value = false;
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(int id) {
    KTAlertDialog.show(
      context,
      title: 'Hapus Transaksi',
      content: 'Apakah Anda yakin ingin menghapus transaksi ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await _supabaseService.deleteFinanceTransaction(id);
          await _fetchTransactions();
          Get.snackbar(
            'Sukses',
            'Transaksi berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KTColor.success,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus transaksi: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KTColor.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: Text(widget.account['name'] ?? 'Detail Akun'),
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

        // Calculate Balance
        int totalIncome = 0;
        int totalExpense = 0;
        for (var t in _transactions) {
          final amount = t['amount'] as int? ?? 0;
          if (t['type'] == 'income') {
            totalIncome += amount;
          } else {
            totalExpense += amount;
          }
        }
        final balance = totalIncome - totalExpense;

        return RefreshIndicator(
          onRefresh: _fetchTransactions,
          color: KTColor.primary,
          child: Column(
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    Text(
                      "Total Saldo Akun",
                      style: TextStyle(
                        color: KTColor.textSecondary.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(balance),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: KTColor.primary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _transactions.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: KTColor.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: KTColor.border.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 60,
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada transaksi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: KTColor.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Klik tombol di bawah untuk menambah',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _transactions[index];
                          final date = DateTime.parse(
                            item['transaction_date'] ?? item['created_at'],
                          );
                          final amount = item['amount'] ?? 0;
                          final title = item['title'] ?? 'Transaksi';
                          final type = item['type'];
                          final isIncome = type == 'income';

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
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      (isIncome
                                              ? KTColor.success
                                              : KTColor.error)
                                          .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isIncome
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: isIncome
                                      ? KTColor.success
                                      : KTColor.error,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: KTColor.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('d MMM yyyy', 'id_ID').format(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount)}",
                                    style: TextStyle(
                                      color: isIncome
                                          ? KTColor.success
                                          : KTColor.error,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: KTColor.error,
                                      size: 20,
                                    ),
                                    onPressed: () => _confirmDelete(item['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 32),
            FloatingActionButton.extended(
              heroTag: 'income',
              onPressed: () => _showTransactionDialog(type: 'income'),
              backgroundColor: KTColor.success,
              elevation: 2,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                "Pemasukan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: 'expense',
              onPressed: () => _showTransactionDialog(type: 'expense'),
              backgroundColor: KTColor.error,
              elevation: 2,
              icon: const Icon(Icons.remove_rounded, color: Colors.white),
              label: const Text(
                "Pengeluaran",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
