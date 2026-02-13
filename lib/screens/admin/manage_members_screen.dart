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
      Get.snackbar('Error', 'Gagal memuat anggota: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Kelola Anggota",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
              onChanged: _filterMembers,
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

                    return Container(
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
                            color: KTColor.textSecondary.withValues(alpha: 0.3),
                          ),
                        ],
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
