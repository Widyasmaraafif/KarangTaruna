import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/bill_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();
    final roleVal =
        controller.userProfile['role']?.toString().toLowerCase() ?? '';
    final bool isGuest = roleVal.isEmpty || roleVal == 'user';

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Keuangan'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isGuest
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block_rounded,
                      size: 64,
                      color: KTColor.border,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Maaf, Anda bukan Anggota Cahya Muda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: KTColor.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fitur keuangan anggota hanya tersedia untuk Anggota Cahya Muda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: KTColor.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
        onRefresh: controller.fetchBills,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.isLoadingBills.value && controller.bills.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final billsData = controller.bills;
          final bills = billsData.map((e) {
            return KTBillingItem(
              title: e['title'],
              description: e['description'] ?? '',
              amount: (e['amount'] as num).toInt(),
              dueDate: DateTime.tryParse(e['due_date']) ?? DateTime.now(),
              isPaid: e['is_paid'] ?? false,
            );
          }).toList();

          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tagihan untuk Anda',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: bills.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return KTBillingCard(bill: bills[index]);
            },
          );
        }),
      ),
    );
  }
}
