import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/services/supabase_service.dart';

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredMembers.assignAll(_members);
    } else {
      _filteredMembers.assignAll(
        _members.where((member) {
          final name = (member['full_name'] ?? '').toString().toLowerCase();
          final email = (member['email'] ?? '').toString().toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList(),
      );
    }
  }

  Future<void> _fetchMembers() async {
    try {
      _isLoading.value = true;
      final members = await _supabaseService.getAllProfiles();
      _members.assignAll(members);
      _filteredMembers.assignAll(members);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data anggota: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateRole(String userId, String currentRole) async {
    final List<String> roles = [
      'Anggota',
      'Ketua',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Admin',
    ];

    String tempRole = currentRole;

    String? selectedRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Role'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return RadioListTile<String>(
                      title: Text(role),
                      value: role,
                      groupValue: tempRole,
                      onChanged: (value) {
                        setState(() {
                          tempRole = value!;
                        });
                      },
                      activeColor: const Color(0xFF00BA9B),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempRole),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (selectedRole != null && selectedRole != currentRole) {
      try {
        await _supabaseService.updateProfileRole(userId, selectedRole);
        Get.snackbar(
          'Sukses',
          'Role berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _fetchMembers(); // Refresh list
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal memperbarui role: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kelola Anggota',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari anggota...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00BA9B)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00BA9B)),
                );
              }

              if (_filteredMembers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada anggota ditemukan',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  final name = member['full_name'] ?? 'User';
                  final role = member['role'] ?? 'Anggota';
                  final avatarUrl = member['avatar_url'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : NetworkImage(
                                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
                              ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                color: _getRoleColor(role),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (member['phone'] != null &&
                              member['phone'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              member['phone'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: const Color(0xFF00BA9B),
                        onPressed: () => _updateRole(member['id'], role),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'ketua':
      case 'wakil ketua':
      case 'bendahara':
      case 'sekretaris':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
