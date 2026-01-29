import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/bill_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keuangan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchBills,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Obx(() {
                    final billsData = controller.bills;
                    final bills = billsData.map((e) {
                      return KTBillingItem(
                        title: e['title'],
                        description: e['description'] ?? '',
                        amount: (e['amount'] as num).toInt(),
                        dueDate:
                            DateTime.tryParse(e['due_date']) ?? DateTime.now(),
                        isPaid: e['is_paid'] ?? false,
                      );
                    }).toList();

                    if (bills.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'tidak ada tagihan saat ini',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: bills
                          .map((bill) => KTBillingCard(bill: bill))
                          .toList(),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
