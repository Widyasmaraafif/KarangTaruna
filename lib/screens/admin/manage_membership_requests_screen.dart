import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class ManageMembershipRequestsScreen extends StatefulWidget {
  const ManageMembershipRequestsScreen({super.key});

  @override
  State<ManageMembershipRequestsScreen> createState() =>
      _ManageMembershipRequestsScreenState();
}

class _ManageMembershipRequestsScreenState
    extends State<ManageMembershipRequestsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final RxList<Map<String, dynamic>> _requests =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      _isLoading.value = true;
      final data = await _supabaseService.getPendingMembershipRequests();
      _requests.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat pengajuan anggota: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _processRequest(
    Map<String, dynamic> request,
    String status,
  ) async {
    final int id = request['id'] as int;
    final String userId = request['user_id']?.toString() ?? '';
    if (userId.isEmpty) return;

    try {
      await _supabaseService.processMembershipRequest(
        id: id,
        status: status,
        userId: userId,
      );
      _requests.removeWhere((r) => r['id'] == id);
      Get.snackbar(
        'Berhasil',
        status == 'approved'
            ? 'Pengajuan anggota disetujui dan role diubah ke Anggota'
            : 'Pengajuan anggota ditolak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            status == 'approved' ? KTColor.success : KTColor.warning,
        colorText: Colors.white,
        icon: Icon(
          status == 'approved'
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
          color: Colors.white,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses pengajuan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Pengajuan Anggota'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: KTColor.border,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pengajuan anggota',
                  style: TextStyle(color: KTColor.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchRequests,
          color: KTColor.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              final String name = request['full_name'] ?? 'User';
              final String email = request['email'] ?? '-';
              final String? reason = request['reason'] as String?;
              final DateTime? createdAt =
                  request['created_at'] != null
                      ? DateTime.tryParse(
                          request['created_at'].toString(),
                        )
                      : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KTColor.border.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: KTColor.primary.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: KTColor.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: KTColor.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: KTColor.textSecondary,
                                ),
                              ),
                              if (createdAt != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Diajukan: ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: KTColor.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (reason != null && reason.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Alasan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: KTColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: KTColor.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _processRequest(
                            request,
                            'rejected',
                          ),
                          child: const Text(
                            'Tolak',
                            style: TextStyle(color: KTColor.error),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _processRequest(
                            request,
                            'approved',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KTColor.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Terima'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

