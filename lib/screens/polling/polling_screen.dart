import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/pooling_card.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class PollingScreen extends StatefulWidget {
  const PollingScreen({super.key});

  @override
  State<PollingScreen> createState() => _PollingScreenState();
}

class _PollingScreenState extends State<PollingScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _pollingFuture;

  // Track voted polls locally to prevent spamming in one session (simple mock prevention)
  // In real app, this should be checked against backend or local storage
  final Set<int> _votedPolls = {};

  @override
  void initState() {
    super.initState();
    _pollingFuture = _supabaseService.getActivePolls();
  }

  Future<void> _refreshPolls() async {
    setState(() {
      _pollingFuture = _supabaseService.getActivePolls();
    });
  }

  Future<void> _handleVote(int pollId, int optionId, String label) async {
    if (_votedPolls.contains(pollId)) {
      Get.snackbar(
        'Info',
        'Anda sudah memilih pada polling ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Optimistic update could be done here, but for simplicity we await
      await _supabaseService.submitVote(optionId);

      setState(() {
        _votedPolls.add(pollId);
      });

      Get.snackbar(
        'Vote Berhasil',
        'Kamu memilih $label',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh to show updated counts
      _refreshPolls();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim vote: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Pooling",
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
      body: RefreshIndicator(
        onRefresh: _refreshPolls,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _pollingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final polls = snapshot.data ?? [];

            // Fallback mock data if empty
            final displayPolls = polls.isEmpty
                ? [
                    {
                      'id': 991,
                      'title':
                          'Kegiatan apa yang kamu pilih minggu ini? (Mock)',
                      'polling_options': [
                        {
                          'id': 1,
                          'label': 'Kerja bakti lingkungan',
                          'vote_count': 40,
                        },
                        {
                          'id': 2,
                          'label': 'Pelatihan keterampilan',
                          'vote_count': 25,
                        },
                        {'id': 3, 'label': 'Lomba olahraga', 'vote_count': 35},
                      ],
                    },
                    {
                      'id': 992,
                      'title': 'Lokasi wisata tahunan? (Mock)',
                      'polling_options': [
                        {'id': 4, 'label': 'Pantai', 'vote_count': 60},
                        {'id': 5, 'label': 'Gunung', 'vote_count': 30},
                        {'id': 6, 'label': 'Museum', 'vote_count': 10},
                      ],
                    },
                  ]
                : polls;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayPolls.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final poll = displayPolls[index];
                final pollId = poll['id'] as int;
                final rawOptions = poll['polling_options'] as List<dynamic>;

                // Parse options
                final options = rawOptions.map((o) {
                  return KTPoolingOption(
                    id: o['id'] as int?,
                    label: o['label'] as String,
                    value: o['vote_count'] as int? ?? 0,
                  );
                }).toList();

                return KTPoolingCard(
                  title: poll['title'] ?? 'Polling',
                  options: options,
                  onOptionTap: (option) {
                    if (option.id != null) {
                      _handleVote(pollId, option.id!, option.label);
                    } else {
                      Get.snackbar('Info', 'Mock vote: ${option.label}');
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
