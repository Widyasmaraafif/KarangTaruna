import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/containers/bill_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final List<KTBillingItem> bills = [
    KTBillingItem(
      title: 'Iuran Kas Bulanan',
      description: 'Iuran kas karang taruna bulan Januari 2026.',
      amount: 50000,
      dueDate: DateTime(2026, 1, 25),
    ),
    KTBillingItem(
      title: 'Iuran Kegiatan',
      description: 'Iuran untuk kegiatan kerja bakti lingkungan RW 05.',
      amount: 30000,
      dueDate: DateTime(2026, 1, 30),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasBills = bills.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    if (!hasBills)
                      const Padding(
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
                      )
                    else
                      Column(
                        children: bills
                            .map((bill) => KTBillingCard(bill: bill))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
