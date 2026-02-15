import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final RxList<Map<String, dynamic>> _members = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _filteredMembers =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _availableRoles = [
    'User',
    'Anggota',
    'Ketua',
    'Wakil Ketua',
    'Sekretaris',
    'Bendahara',
    'Admin',
    'Pubdekdok',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      _isLoading.value = true;
      final members = await _supabaseService.getUsers();
      _members.assignAll(members);
      _filteredMembers.assignAll(members);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat anggota: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KTColor.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterMembers(String query) {
    if (query.isEmpty) {
      _filteredMembers.assignAll(_members);
    } else {
      _filteredMembers.assignAll(
        _members.where(
          (m) =>
              (m['full_name'] ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              (m['email'] ?? '').toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void _showMemberDetail(Map<String, dynamic> member) {
    final String userId = member['id']?.toString() ?? '';
    if (userId.isEmpty) return;

    String currentRole =
        (member['role'] as String?)?.isNotEmpty == true ? member['role'] : 'User';
    String tempRole = currentRole;

    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: KTColor.border.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                member['avatar_url'] ??
                                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(member['full_name'] ?? member['email'] ?? 'User')}&background=random',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['full_name'] ?? 'User',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: KTColor.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member['email'] ?? '-',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: KTColor.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Peran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KTColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableRoles.length,
                        itemBuilder: (context, index) {
                          final role = _availableRoles[index];
                          return RadioListTile<String>(
                            value: role,
                            groupValue: tempRole,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                tempRole = value;
                              });
                            },
                            title: Text(
                              role,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (tempRole == currentRole) {
                                    Navigator.of(context).pop();
                                    return;
                                  }
                                  try {
                                    setState(() {
                                      isSaving = true;
                                    });
                                    await _supabaseService.updateProfileRole(
                                      userId,
                                      tempRole,
                                    );
                                    final index = _members.indexWhere(
                                        (m) => m['id'] == member['id']);
                                    if (index != -1) {
                                      _members[index]['role'] = tempRole;
                                    }
                                    final filteredIndex =
                                        _filteredMembers.indexWhere(
                                            (m) => m['id'] == member['id']);
                                    if (filteredIndex != -1) {
                                      _filteredMembers[filteredIndex]['role'] =
                                          tempRole;
                                    }
                                    Get.snackbar(
                                      'Berhasil',
                                      'Peran anggota berhasil diperbarui',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: KTColor.success,
                                      colorText: Colors.white,
                                      icon: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    setState(() {
                                      isSaving = false;
                                    });
                                    Get.snackbar(
                                      'Error',
                                      'Gagal memperbarui peran: $e',
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KTColor.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Kelola Anggota'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: KTColor.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: KTTextField(
              controller: _searchController,
              hintText: 'Cari anggota...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              onChanged: _filterMembers, labelText: '',
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: KTColor.primary),
                );
              }

              if (_filteredMembers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: KTColor.border,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Anggota tidak ditemukan',
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
                onRefresh: _fetchMembers,
                color: KTColor.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredMembers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = _filteredMembers[index];
                    final name = member['full_name'] ?? 'User';
                    final email = member['email'] ?? '-';
                    final role = member['role'] ?? 'anggota';
                    final avatarUrl =
                        member['avatar_url'] ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';

                    return InkWell(
                      onTap: () => _showMemberDetail(member),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: KTColor.border.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: KTColor.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: KTColor.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: KTColor.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                role.toString().toUpperCase(),
                                style: const TextStyle(
                                  color: KTColor.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color:
                                  KTColor.textSecondary.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
