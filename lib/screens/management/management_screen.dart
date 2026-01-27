import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _service = SupabaseService();
  late Future<List<Map<String, dynamic>>> _managementFuture;

  @override
  void initState() {
    super.initState();
    _managementFuture = _service.getManagement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Pengurus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _managementFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fallback data if API fails or returns empty (for demo purposes)
          var members = snapshot.data ?? [];
          if (members.isEmpty) {
            members = [
              {
                'name': 'Budi Santoso',
                'position': 'Ketua Karang Taruna',
                'image_url':
                    'https://ui-avatars.com/api/?name=Budi+Santoso&background=0D8ABC&color=fff',
              },
              {
                'name': 'Siti Aminah',
                'position': 'Sekretaris',
                'image_url':
                    'https://ui-avatars.com/api/?name=Siti+Aminah&background=random',
              },
              {
                'name': 'Ahmad Rizki',
                'position': 'Bendahara',
                'image_url':
                    'https://ui-avatars.com/api/?name=Ahmad+Rizki&background=random',
              },
              {
                'name': 'Dewi Ratna',
                'position': 'Koordinator Acara',
                'image_url':
                    'https://ui-avatars.com/api/?name=Dewi+Ratna&background=random',
              },
              {
                'name': 'Rudi Hartono',
                'position': 'Humas',
                'image_url':
                    'https://ui-avatars.com/api/?name=Rudi+Hartono&background=random',
              },
            ];
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      member['image_url'] ??
                          'https://ui-avatars.com/api/?name=${member['name']}&background=random',
                    ),
                  ),
                  title: Text(
                    member['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    member['position'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Show detail dialog or navigate
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                member['image_url'] ??
                                    'https://ui-avatars.com/api/?name=${member['name']}&background=random',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              member['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(member['position']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
