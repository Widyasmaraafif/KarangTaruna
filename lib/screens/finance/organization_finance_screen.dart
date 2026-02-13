import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/finance/widgets/finance_account_detail_screen.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class OrganizationFinanceScreen extends StatelessWidget {
  const OrganizationFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    // Map string icon names to IconData
    final Map<String, IconData> iconMap = {
      'account_balance': Icons.account_balance_rounded,
      'sports_soccer': Icons.sports_soccer_rounded,
      'people': Icons.people_rounded,
      'money': Icons.attach_money_rounded,
      'default': Icons.account_balance_wallet_rounded,
    };

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Keuangan Organisasi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchFinanceAccounts,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.isLoadingFinanceAccounts.value &&
              controller.financeAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.financeAccounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada akun keuangan',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: controller.financeAccounts.length,
            itemBuilder: (context, index) {
              final account = controller.financeAccounts[index];
              final name = account['name'] ?? 'Kas';
              final description = account['description'] ?? '';
              final iconName = account['icon'] ?? 'default';
              final colorHex = account['color'] ?? '0xFF00BA9B';

              final color = Color(int.parse(colorHex));
              final icon = iconMap[iconName] ?? iconMap['default']!;

              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => FinanceAccountDetailScreen(account: account),
                    transition: Transition.cupertino,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KTColor.border.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: KTColor.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: KTColor.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: KTColor.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
