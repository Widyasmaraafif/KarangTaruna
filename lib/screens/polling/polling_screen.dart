import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/pooling_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class PollingScreen extends StatelessWidget {
  const PollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

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
        onRefresh: controller.fetchPolls,
        child: Obx(() {
          final polls = controller.polls;

          if (polls.isEmpty && !controller.isLoadingPolls.value) {
            return const Center(child: Text('Belum ada polling aktif'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final poll = polls[index];
              final pollId = poll['id'];
              final isVoted = controller.votedPollIds.contains(pollId);

              // Calculate total votes for this poll
              final options = (poll['polling_options'] as List<dynamic>? ?? []);
              int totalVotes = 0;
              for (var opt in options) {
                totalVotes += (opt['vote_count'] as num? ?? 0).toInt();
              }

              return KTPollingCard(
                question: poll['title'] ?? 'No Question',
                options: options.map((e) => e as Map<String, dynamic>).toList(),
                totalVotes: totalVotes,
                isVoted: isVoted,
                onVote: (optionId, label) async {
                  if (isVoted) {
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
                    await controller.votePoll(pollId, optionId);
                    Get.snackbar(
                      'Vote Berhasil',
                      'Kamu memilih $label',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Gagal mengirim vote: $e',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }
}
