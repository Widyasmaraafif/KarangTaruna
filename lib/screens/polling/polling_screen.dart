import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/polling_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/polling/polling_detail_screen.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class PollingScreen extends StatelessWidget {
  const PollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Polling'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchPolls,
        color: KTColor.primary,
        child: Obx(() {
          final polls = controller.polls;

          if (polls.isEmpty && controller.isLoadingPolls.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (polls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.poll_outlined, size: 64, color: KTColor.border),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada polling aktif',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: polls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
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
                onCardTap: () {
                  Get.to(
                    () => PollingDetailScreen(poll: poll),
                    transition: Transition.cupertino,
                  );
                },
                onVote: (optionId, label) async {
                  if (isVoted) {
                    Get.snackbar(
                      'Info',
                      'Anda sudah memilih pada polling ini',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: KTColor.warning,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    await controller.votePoll(pollId, optionId);
                    Get.snackbar(
                      'Vote Berhasil',
                      'Kamu memilih $label',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: KTColor.success,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    final message = e.toString().replaceAll('Exception: ', '');
                    Get.snackbar(
                      'Info',
                      message,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: message.contains('sudah memilih')
                          ? KTColor.warning
                          : KTColor.error,
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
