import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManagePollingController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  var polls = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPolls();
  }

  Future<void> fetchPolls({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final data = await _supabaseService.getAllPolls();
      polls.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data polling: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> createPoll(String question, List<String> options) async {
    if (question.isEmpty || options.length < 2) {
      Get.snackbar(
        'Error',
        'Pertanyaan dan minimal 2 opsi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    // Filter empty options
    final validOptions = options.where((o) => o.trim().isNotEmpty).toList();
    if (validOptions.length < 2) {
      Get.snackbar(
        'Error',
        'Minimal 2 opsi valid diperlukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    try {
      isLoading.value = true;
      await _supabaseService.createPoll(question, validOptions);
      Get.back(); // Close dialog
      Get.snackbar(
        'Sukses',
        'Polling berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.success,
        colorText: Colors.white,
        icon: const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
        ),
      );
      fetchPolls();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat polling: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
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
      Get.snackbar(
        'Error',
        'Pertanyaan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    if (updatedOptions.length < 2) {
      Get.snackbar(
        'Error',
        'Minimal 2 opsi diperlukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
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
      Get.snackbar(
        'Sukses',
        'Polling berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.success,
        colorText: Colors.white,
        icon: const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
        ),
      );
      fetchPolls();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui polling: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePoll(int id) async {
    try {
      isLoading.value = true;
      await _supabaseService.deletePoll(id);
      Get.snackbar(
        'Sukses',
        'Polling berhasil dihapus',
        backgroundColor: KTColor.success,
        colorText: Colors.white,
      );
      fetchPolls();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus polling: $e',
        backgroundColor: KTColor.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(int id, bool currentStatus) async {
    try {
      await _supabaseService.updatePollStatus(id, !currentStatus);
      fetchPolls(silent: true); // Refresh list to update UI
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status: $e',
        backgroundColor: KTColor.error,
        colorText: Colors.white,
      );
    }
  }
}

class ManagePollingScreen extends StatelessWidget {
  const ManagePollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagePollingController());

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Kelola Polling'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: KTColor.primary),
          );
        }

        if (controller.polls.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.poll_outlined, size: 64, color: KTColor.border),
                const SizedBox(height: 16),
                Text(
                  'Belum ada polling',
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
          onRefresh: () => controller.fetchPolls(silent: true),
          color: KTColor.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.polls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final poll = controller.polls[index];
              final options = (poll['polling_options'] as List<dynamic>?) ?? [];
              final totalVotes = options.fold<int>(
                0,
                (sum, item) => sum + (item['vote_count'] as int? ?? 0),
              );
              final isActive = poll['is_active'] as bool? ?? false;

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
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      poll['title'] ?? 'Tanpa Pertanyaan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: KTColor.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isActive ? KTColor.success : KTColor.error)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isActive ? "Aktif" : "Tidak Aktif",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? KTColor.success
                                    : KTColor.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${options.length} Opsi • $totalVotes Suara',
                            style: TextStyle(
                              color: KTColor.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 24),
                            ...options.map((opt) {
                              final count = opt['vote_count'] as int? ?? 0;
                              final percentage = totalVotes > 0
                                  ? (count / totalVotes)
                                  : 0.0;
                              final percentageText = totalVotes > 0
                                  ? (count / totalVotes * 100).toStringAsFixed(
                                      1,
                                    )
                                  : '0.0';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opt['label'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: KTColor.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$count suara ($percentageText%)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: KTColor.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage.toDouble(),
                                        backgroundColor: KTColor.border
                                            .withValues(alpha: 0.3),
                                        color: KTColor.primary,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton(
                                  onPressed: () => _showPollForm(
                                    context,
                                    controller,
                                    poll: poll,
                                  ),
                                  icon: Icons.edit_rounded,
                                  label: 'Edit',
                                  color: KTColor.primary,
                                ),
                                const SizedBox(width: 12),
                                _buildActionButton(
                                  onPressed: () => controller.toggleStatus(
                                    poll['id'],
                                    isActive,
                                  ),
                                  icon: isActive
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  label: isActive ? 'Nonaktifkan' : 'Aktifkan',
                                  color: isActive
                                      ? KTColor.warning
                                      : KTColor.success,
                                ),
                                const SizedBox(width: 12),
                                _buildActionButton(
                                  onPressed: () => _confirmDelete(
                                    context,
                                    controller,
                                    poll['id'],
                                  ),
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Hapus',
                                  color: KTColor.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPollForm(context, controller),
        backgroundColor: KTColor.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
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

    final isSaving = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Polling' : 'Buat Polling Baru',
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
              controller: questionController,
              labelText: 'Pertanyaan',
              hintText: 'Masukkan pertanyaan polling',
              prefixIcon: const Icon(Icons.help_outline_rounded),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Opsi Polling',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: KTColor.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    optionControllers.add({
                      'controller': TextEditingController(),
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Tambah Opsi'),
                  style: TextButton.styleFrom(
                    foregroundColor: KTColor.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: optionControllers.length,
                  itemBuilder: (context, index) {
                    final item = optionControllers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: KTTextField(
                              controller:
                                  item['controller'] as TextEditingController,
                              hintText: 'Opsi ${index + 1}', labelText: '',
                            ),
                          ),
                          if (optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: KTColor.error,
                                size: 22,
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
            const SizedBox(height: 24),
            Obx(
              () => KTButton(
                text: isEditing ? 'Simpan Perubahan' : 'Buat Polling',
                isLoading: isSaving.value,
                onPressed: () async {
                  final validOptions = optionControllers
                      .where(
                        (item) => (item['controller'] as TextEditingController)
                            .text
                            .trim()
                            .isNotEmpty,
                      )
                      .toList();

                  if (questionController.text.isEmpty ||
                      validOptions.length < 2) {
                    Get.snackbar(
                      'Peringatan',
                      'Pertanyaan dan minimal 2 opsi harus diisi',
                      backgroundColor: KTColor.warning,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  isSaving.value = true;
                  try {
                    if (isEditing) {
                      final updatedOptions = validOptions.map((item) {
                        return {
                          if (item['id'] != null) 'id': item['id'],
                          'label': (item['controller'] as TextEditingController)
                              .text,
                        };
                      }).toList();

                      await controller.updatePoll(
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
                      await controller.createPoll(
                        questionController.text,
                        options,
                      );
                    }
                  } finally {
                    isSaving.value = false;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}
