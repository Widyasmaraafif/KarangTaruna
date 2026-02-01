import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';

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
      Get.snackbar('Error', 'Gagal memuat transaksi: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _showTransactionDialog({String type = 'income'}) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    // Default to today
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == 'income' ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                KTTextField(
                  controller: titleController,
                  labelText: 'Judul Transaksi',
                  hintText: 'Contoh: Iuran Bulanan / Beli Peralatan',
                ),
                const SizedBox(height: 12),
                KTTextField(
                  controller: amountController,
                  labelText: 'Nominal (Rp)',
                  hintText: 'Contoh: 500000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                KTTextField(
                  controller: descriptionController,
                  labelText: 'Keterangan (Opsional)',
                  hintText: 'Detail tambahan...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Tanggal Transaksi",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        selectedDate.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(selectedDate.value),
                          ),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
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
                      backgroundColor: type == 'income'
                          ? Colors.green
                          : Colors.red,
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            amountController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Judul dan Nominal wajib diisi',
                          );
                          return;
                        }

                        try {
                          final amount =
                              int.tryParse(amountController.text) ?? 0;

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
                          Navigator.of(context).pop();
                          Get.snackbar('Sukses', 'Transaksi berhasil disimpan');
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan transaksi: $e',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: 'Hapus Transaksi',
      middleText: 'Apakah Anda yakin ingin menghapus transaksi ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          await _supabaseService.deleteFinanceTransaction(id);
          await _fetchTransactions();
          Get.back();
          Get.snackbar('Sukses', 'Transaksi berhasil dihapus');
        } catch (e) {
          Get.snackbar('Error', 'Gagal menghapus transaksi: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.account['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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

        return Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Saldo",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(balance),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BA9B),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _transactions.isEmpty
                  ? const Center(child: Text("Belum ada transaksi"))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _transactions[index];
                        final date = DateTime.parse(
                          item['transaction_date'] ?? item['created_at'],
                        );
                        final amount = item['amount'] ?? 0;
                        final title = item['title'] ?? 'Transaksi';
                        final type = item['type'];
                        final isIncome = type == 'income';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? Colors.green[50]
                                : Colors.red[50],
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat('d MMM yyyy').format(date),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount)}",
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () => _confirmDelete(item['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'income',
            onPressed: () => _showTransactionDialog(type: 'income'),
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add),
            label: const Text("Pemasukan"),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'expense',
            onPressed: () => _showTransactionDialog(type: 'expense'),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.remove),
            label: const Text("Pengeluaran"),
          ),
        ],
      ),
    );
  }
}
