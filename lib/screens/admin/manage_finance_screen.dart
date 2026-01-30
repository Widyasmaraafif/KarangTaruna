import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';

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
      Get.snackbar('Error', 'Gagal memuat data keuangan: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteBill(int id) async {
    Get.defaultDialog(
      title: 'Hapus Tagihan',
      middleText: 'Apakah Anda yakin ingin menghapus tagihan ini?',
      textConfirm: 'Ya, Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          Get.back(); // Close dialog
          await _supabaseService.deleteBill(id);
          await _fetchData();
          _dataController.fetchBills(); // Update global state
          Get.snackbar(
            'Sukses',
            'Tagihan berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus tagihan: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
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
    final descriptionController =
        TextEditingController(text: bill?['description']);
    final dueDateController = TextEditingController(
      text: bill != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(bill['due_date']))
          : '',
    );

    String? selectedUserId = bill?['user_id'];
    String? selectedStatus = bill?['status'] ?? 'pending';

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bill == null ? 'Buat Tagihan Baru' : 'Edit Tagihan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BA9B),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Anggota',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tagihan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Jatuh Tempo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      dueDateController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Pembayaran',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Belum Lunas')),
                    DropdownMenuItem(value: 'paid', child: Text('Lunas')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedUserId == null ||
                          titleController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          dueDateController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Mohon lengkapi data wajib',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      try {
                        final data = {
                          'user_id': selectedUserId,
                          'title': titleController.text,
                          'amount': int.tryParse(amountController.text) ?? 0,
                          'due_date': dueDateController.text,
                          'status': selectedStatus,
                          'description': descriptionController.text,
                          'updated_at': DateTime.now().toIso8601String(),
                        };

                        if (bill == null) {
                          data['created_at'] = DateTime.now().toIso8601String();
                          await _supabaseService.createBill(data);
                          Get.snackbar('Sukses', 'Tagihan berhasil dibuat');
                        } else {
                          await _supabaseService.updateBill(bill['id'], data);
                          Get.snackbar('Sukses', 'Tagihan berhasil diperbarui');
                        }

                        Get.back(); // Close bottom sheet
                        _fetchData(); // Refresh list
                        _dataController.fetchBills(); // Update global state
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Gagal menyimpan tagihan: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BA9B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(bill == null ? 'Simpan' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kelola Keuangan',
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
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00BA9B)),
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
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data keuangan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _bills.length,
          itemBuilder: (context, index) {
            final bill = _bills[index];
            final isPaid = bill['status'] == 'paid';
            final dueDate = DateTime.parse(bill['due_date']);
            final amount = NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(bill['amount']);
            
            // Handle join data if available (Supabase returns related data in nested map)
            final memberName = bill['profiles']?['full_name'] ?? 'Unknown User';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        bill['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPaid ? 'LUNAS' : 'BELUM LUNAS',
                        style: TextStyle(
                          color: isPaid ? Colors.green : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00BA9B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          memberName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
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
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBillForm(),
        backgroundColor: const Color(0xFF00BA9B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
