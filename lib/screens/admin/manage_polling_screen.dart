import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
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

  Future<void> updatePoll({
    required int id,
    required String question,
    required List<Map<String, dynamic>> updatedOptions,
    required List<int> deletedOptionIds,
  }) async {
    if (question.isEmpty) {
      Get.snackbar('Error', 'Pertanyaan tidak boleh kosong');
      return;
    }

    if (updatedOptions.length < 2) {
      Get.snackbar('Error', 'Minimal 2 opsi diperlukan');
      return;
    }

    try {
      isLoading.value = true;
      await _supabaseService.updatePollFull(
        pollId: id,
        question: question,
        updatedOptions: updatedOptions,
        deletedOptionIds: deletedOptionIds,
      );
      Get.back(); // Close dialog
      Get.snackbar('Sukses', 'Polling berhasil diperbarui');
      fetchPolls();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui polling: $e');
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
      appBar: AppBar(title: const Text('Kelola Poling')),
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
            final totalVotes = options.fold<int>(
              0,
              (sum, item) => sum + (item['vote_count'] as int? ?? 0),
            );
            final isActive = poll['is_active'] as bool? ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  poll['title'] ?? 'Tanpa Pertanyaan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${options.length} Opsi • $totalVotes Total Suara • ${isActive ? "Aktif" : "Tidak Aktif"}',
                  style: TextStyle(color: isActive ? Colors.green : Colors.red),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...options.map((opt) {
                          final count = opt['vote_count'] as int? ?? 0;
                          final percentage = totalVotes > 0
                              ? (count / totalVotes * 100).toStringAsFixed(1)
                              : '0.0';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(opt['label'] ?? ''),
                                    Text('$count suara ($percentage%)'),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: totalVotes > 0
                                      ? count / totalVotes
                                      : 0,
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showPollForm(
                                context,
                                controller,
                                poll: poll,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () =>
                                  controller.toggleStatus(poll['id'], isActive),
                              icon: Icon(
                                isActive ? Icons.pause : Icons.play_arrow,
                              ),
                              label: Text(
                                isActive ? 'Nonaktifkan' : 'Aktifkan',
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmDelete(
                                context,
                                controller,
                                poll['id'],
                              ),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
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
        onPressed: () => _showPollForm(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ManagePollingController controller,
    int id,
  ) {
    KTAlertDialog.show(
      context,
      title: 'Hapus Polling',
      content: 'Apakah Anda yakin ingin menghapus polling ini?',
      onConfirm: () => controller.deletePoll(id),
    );
  }

  void _showPollForm(
    BuildContext context,
    ManagePollingController controller, {
    Map<String, dynamic>? poll,
  }) {
    final isEditing = poll != null;
    final questionController = TextEditingController(text: poll?['title']);

    // Track original IDs to detect deletions
    final existingOptions = isEditing
        ? List<Map<String, dynamic>>.from(poll['polling_options'] ?? [])
        : <Map<String, dynamic>>[];
    final originalOptionIds = existingOptions
        .map((e) => e['id'] as int)
        .toSet();
    final deletedOptionIds = <int>[];

    // Structure: {'id': int?, 'controller': TextEditingController}
    final optionControllers = RxList<Map<String, dynamic>>([]);

    if (isEditing) {
      for (var opt in existingOptions) {
        optionControllers.add({
          'id': opt['id'],
          'controller': TextEditingController(text: opt['label']),
        });
      }
    } else {
      optionControllers.add({'controller': TextEditingController()});
      optionControllers.add({'controller': TextEditingController()});
    }

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
            Text(
              isEditing ? 'Edit Polling' : 'Buat Polling Baru',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: optionControllers.length,
                  itemBuilder: (context, index) {
                    final item = optionControllers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  item['controller'] as TextEditingController,
                              decoration: InputDecoration(
                                labelText: 'Opsi ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // If removing an existing option, mark ID as deleted
                                if (item['id'] != null) {
                                  deletedOptionIds.add(item['id'] as int);
                                }
                                optionControllers.removeAt(index);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                optionControllers.add({'controller': TextEditingController()});
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Opsi'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final validOptions = optionControllers
                      .where(
                        (item) => (item['controller'] as TextEditingController)
                            .text
                            .trim()
                            .isNotEmpty,
                      )
                      .toList();

                  if (isEditing) {
                    final updatedOptions = validOptions.map((item) {
                      return {
                        if (item['id'] != null) 'id': item['id'],
                        'label':
                            (item['controller'] as TextEditingController).text,
                      };
                    }).toList();

                    controller.updatePoll(
                      id: poll['id'],
                      question: questionController.text,
                      updatedOptions: updatedOptions,
                      deletedOptionIds: deletedOptionIds,
                    );
                  } else {
                    final options = validOptions
                        .map(
                          (item) =>
                              (item['controller'] as TextEditingController)
                                  .text,
                        )
                        .toList();
                    controller.createPoll(questionController.text, options);
                  }
                },
                child: Text(isEditing ? 'Simpan Perubahan' : 'Buat Polling'),
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
