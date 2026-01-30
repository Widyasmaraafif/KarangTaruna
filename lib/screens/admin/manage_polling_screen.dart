import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class ManagePollingController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  var polls = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPolls();
  }

  Future<void> fetchPolls() async {
    isLoading.value = true;
    try {
      final data = await _supabaseService.getAllPolls();
      polls.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data polling: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPoll(String question, List<String> options) async {
    if (question.isEmpty || options.length < 2) {
      Get.snackbar('Error', 'Pertanyaan dan minimal 2 opsi harus diisi');
      return;
    }
    
    // Filter empty options
    final validOptions = options.where((o) => o.trim().isNotEmpty).toList();
    if (validOptions.length < 2) {
      Get.snackbar('Error', 'Minimal 2 opsi valid diperlukan');
      return;
    }

    try {
      isLoading.value = true;
      await _supabaseService.createPoll(question, validOptions);
      Get.back(); // Close dialog
      Get.snackbar('Sukses', 'Polling berhasil dibuat');
      fetchPolls();
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat polling: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePoll(int id) async {
    try {
      isLoading.value = true;
      await _supabaseService.deletePoll(id);
      Get.snackbar('Sukses', 'Polling berhasil dihapus');
      fetchPolls();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus polling: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(int id, bool currentStatus) async {
    try {
      await _supabaseService.updatePollStatus(id, !currentStatus);
      fetchPolls(); // Refresh list to update UI
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status: $e');
    }
  }
}

class ManagePollingScreen extends StatelessWidget {
  const ManagePollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagePollingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Poling'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.polls.isEmpty) {
          return const Center(child: Text('Belum ada polling'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.polls.length,
          itemBuilder: (context, index) {
            final poll = controller.polls[index];
            final options = (poll['polling_options'] as List<dynamic>?) ?? [];
            final totalVotes = options.fold<int>(0, (sum, item) => sum + (item['vote_count'] as int? ?? 0));
            final isActive = poll['is_active'] as bool? ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  poll['question'] ?? 'Tanpa Pertanyaan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${options.length} Opsi • $totalVotes Total Suara • ${isActive ? "Aktif" : "Tidak Aktif"}',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...options.map((opt) {
                          final count = opt['vote_count'] as int? ?? 0;
                          final percentage = totalVotes > 0 ? (count / totalVotes * 100).toStringAsFixed(1) : '0.0';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(opt['option_text'] ?? ''),
                                    Text('$count suara ($percentage%)'),
                                  ],
                                ),
                                LinearProgressIndicator(value: totalVotes > 0 ? count / totalVotes : 0),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => controller.toggleStatus(poll['id'], isActive),
                              icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
                              label: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmDelete(context, controller, poll['id']),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPollDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ManagePollingController controller, int id) {
    Get.defaultDialog(
      title: 'Hapus Polling',
      middleText: 'Apakah Anda yakin ingin menghapus polling ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.deletePoll(id);
      },
    );
  }

  void _showAddPollDialog(BuildContext context, ManagePollingController controller) {
    final questionController = TextEditingController();
    // Start with 2 empty option controllers
    final optionControllers = RxList<TextEditingController>([
      TextEditingController(),
      TextEditingController(),
    ]);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Buat Polling Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Pertanyaan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Opsi ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        if (optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              optionControllers.removeAt(index);
                            },
                          ),
                      ],
                    ),
                  );
                },
              )),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                optionControllers.add(TextEditingController());
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Opsi'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final options = optionControllers.map((c) => c.text).toList();
                  controller.createPoll(questionController.text, options);
                },
                child: const Text('Buat Polling'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}
