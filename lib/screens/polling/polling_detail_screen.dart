import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class PollingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> poll;

  const PollingDetailScreen({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Polling",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Re-fetch the specific poll data from the controller list to get updates
        final currentPoll = controller.polls.firstWhere(
          (p) => p['id'] == poll['id'],
          orElse: () => poll,
        );

        final pollId = currentPoll['id'];
        final isVoted = controller.votedPollIds.contains(pollId);
        final title = currentPoll['title'] ?? 'No Question';

        final options =
            (currentPoll['polling_options'] as List<dynamic>? ?? []);
        int totalVotes = 0;
        for (var opt in options) {
          totalVotes += (opt['vote_count'] as num? ?? 0).toInt();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BA9B), Color(0xFF009A8B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BA9B).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVoted
                                    ? Icons.check_circle
                                    : Icons.how_to_vote,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVoted ? "Sudah Memilih" : "Sedang Berjalan",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.bar_chart, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$totalVotes Suara Masuk",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "Pilihan Anda",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Options List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final optionId = option['id'];
                  final label = option['label'] ?? 'Option';
                  final votes = (option['vote_count'] as num? ?? 0).toInt();
                  final ratio = totalVotes > 0 ? votes / totalVotes : 0.0;
                  final percent = (ratio * 100).round();

                  // Check if this specific option was the one voted for would require tracking vote ID
                  // For now we just show results if voted

                  return GestureDetector(
                    onTap: isVoted
                        ? null
                        : () async {
                            try {
                              await controller.votePoll(pollId, optionId);
                              Get.snackbar(
                                'Terima Kasih!',
                                'Suara anda telah direkam untuk "$label"',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF00BA9B),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(20),
                                borderRadius: 12,
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Gagal',
                                'Terjadi kesalahan saat mengirim vote',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                    child: Container(
                      height: 60, // Fixed height for consistent look
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isVoted
                              ? Colors.grey.shade200
                              : const Color(0xFF00BA9B).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Progress Bar Background
                          if (isVoted)
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutExpo,
                              widthFactor: ratio,
                              heightFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00BA9B,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // Radio-like indicator
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isVoted
                                          ? const Color(0xFF00BA9B)
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    color: isVoted
                                        ? const Color(0xFF00BA9B)
                                        : Colors.transparent,
                                  ),
                                  child: isVoted
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isVoted) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "$percent%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF00BA9B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (!isVoted) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    "Pilih salah satu opsi di atas untuk memberikan suara.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
