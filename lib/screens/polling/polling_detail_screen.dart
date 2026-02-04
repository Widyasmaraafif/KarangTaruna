import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:intl/intl.dart';

class PollingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> poll;

  const PollingDetailScreen({super.key, required this.poll});

  @override
  State<PollingDetailScreen> createState() => _PollingDetailScreenState();
}

class _PollingDetailScreenState extends State<PollingDetailScreen> {
  final _selectedOptionId = RxnInt();
  final _isSubmitting = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly grey background
      appBar: AppBar(
        title: const Text(
          "Detail Polling",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          (p) => p['id'] == widget.poll['id'],
          orElse: () => widget.poll,
        );

        final pollId = currentPoll['id'];
        final isVoted = controller.votedPollIds.contains(pollId);
        final title = currentPoll['title'] ?? 'No Question';
        final description = currentPoll['description'] ?? '';

        final options =
            (currentPoll['polling_options'] as List<dynamic>? ?? []);
        int totalVotes = 0;
        for (var opt in options) {
          totalVotes += (opt['vote_count'] as num? ?? 0).toInt();
        }

        // Sort options by vote count if voted, otherwise keep original order
        final displayOptions = List.from(options);
        if (isVoted) {
          displayOptions.sort((a, b) {
            final votesA = (a['vote_count'] as num? ?? 0).toInt();
            final votesB = (b['vote_count'] as num? ?? 0).toInt();
            return votesB.compareTo(votesA); // Descending
          });
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poll Question Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isVoted
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isVoted
                                          ? Icons.check_circle
                                          : Icons.how_to_vote,
                                      color: isVoted
                                          ? Colors.green[700]
                                          : const Color(0xFF00BA9B),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isVoted
                                          ? "Sudah Memilih"
                                          : "Sedang Berjalan",
                                      style: TextStyle(
                                        color: isVoted
                                            ? Colors.green[700]
                                            : const Color(0xFF00BA9B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$totalVotes",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      isVoted ? "Hasil Voting" : "Pilihan Tersedia",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayOptions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = displayOptions[index];
                        final optionId = option['id'];
                        final label = option['label'] ?? 'Option';
                        final votes = (option['vote_count'] as num? ?? 0)
                            .toInt();
                        final ratio = totalVotes > 0 ? votes / totalVotes : 0.0;
                        final percent = (ratio * 100).toStringAsFixed(1);

                        final isSelected = _selectedOptionId.value == optionId;

                        return GestureDetector(
                          onTap: isVoted
                              ? null
                              : () {
                                  _selectedOptionId.value = optionId;
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: isVoted ? 64 : 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00BA9B)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(
                                          0xFF00BA9B,
                                        ).withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Progress Bar Background (Only if voted)
                                if (isVoted)
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    curve: Curves.easeOutExpo,
                                    widthFactor: ratio,
                                    heightFactor: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00BA9B,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),

                                // Content
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      // Radio Indicator
                                      if (!isVoted) ...[
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF00BA9B)
                                                  : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? const Color(0xFF00BA9B)
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                      ],

                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected || isVoted
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      if (isVoted) ...[
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "$percent%",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF00BA9B),
                                              ),
                                            ),
                                            Text(
                                              "$votes Suara",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
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
                    const SizedBox(height: 100), // Space for FAB/Button
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            if (!isVoted)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _selectedOptionId.value == null || _isSubmitting.value
                          ? null
                          : () async {
                              _isSubmitting.value = true;
                              try {
                                await controller.votePoll(
                                  pollId,
                                  _selectedOptionId.value!,
                                );
                                Get.back(); // Close screen or stay? Stay is better to show results
                                Get.snackbar(
                                  'Berhasil!',
                                  'Suara anda telah direkam',
                                  snackPosition: SnackPosition.TOP,
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
                                final message = e.toString().replaceAll(
                                  'Exception: ',
                                  '',
                                );
                                Get.snackbar(
                                  'Info',
                                  message,
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor:
                                      message.contains('sudah memilih')
                                      ? Colors.orange
                                      : Colors.redAccent,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(20),
                                  borderRadius: 12,
                                );
                              } finally {
                                _isSubmitting.value = false;
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BA9B),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kirim Pilihan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
