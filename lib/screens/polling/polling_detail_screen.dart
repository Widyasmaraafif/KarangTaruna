import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

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

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Detail Polling'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
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
                        border: Border.all(color: KTColor.border),
                        boxShadow: [
                          BoxShadow(
                            color: KTColor.shadow.withOpacity(0.05),
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
                                      ? KTColor.success.withOpacity(0.1)
                                      : KTColor.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isVoted
                                          ? Icons.check_circle_rounded
                                          : Icons.how_to_vote_rounded,
                                      color: isVoted
                                          ? KTColor.success
                                          : KTColor.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isVoted
                                          ? "Sudah Memilih"
                                          : "Sedang Berjalan",
                                      style: TextStyle(
                                        color: isVoted
                                            ? KTColor.success
                                            : KTColor.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
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
                                  color: KTColor.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline_rounded,
                                      size: 16,
                                      color: KTColor.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$totalVotes",
                                      style: const TextStyle(
                                        color: KTColor.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
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
                              color: KTColor.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: const TextStyle(
                                color: KTColor.textSecondary,
                                fontSize: 15,
                                height: 1.6,
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
                        fontWeight: FontWeight.w800,
                        color: KTColor.textPrimary,
                        letterSpacing: -0.5,
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
                                    ? KTColor.primary
                                    : KTColor.border,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? KTColor.primary.withOpacity(0.1)
                                      : KTColor.shadow.withOpacity(0.05),
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
                                        color: KTColor.primary.withOpacity(0.1),
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
                                                  ? KTColor.primary
                                                  : KTColor.border,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? KTColor.primary
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check_rounded,
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
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: KTColor.textPrimary,
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
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                color: KTColor.primary,
                                              ),
                                            ),
                                            Text(
                                              "$votes Suara",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: KTColor.textSecondary,
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
                      color: KTColor.shadow.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: KTButton(
                    text: 'Kirim Pilihan',
                    isLoading: _isSubmitting.value,
                    onPressed: _selectedOptionId.value == null
                        ? null
                        : () async {
                            _isSubmitting.value = true;
                            try {
                              await controller.votePoll(
                                pollId,
                                _selectedOptionId.value!,
                              );
                              Get.snackbar(
                                'Berhasil!',
                                'Suara anda telah direkam',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: KTColor.success,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(20),
                                borderRadius: 12,
                                icon: const Icon(
                                  Icons.check_circle_rounded,
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
                                    ? KTColor.warning
                                    : KTColor.error,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(20),
                                borderRadius: 12,
                              );
                            } finally {
                              _isSubmitting.value = false;
                            }
                          },
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
