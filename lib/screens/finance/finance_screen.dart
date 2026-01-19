import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/containers/bill_card.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = _supabaseService.getBills();
  }

  @override
  Widget build(BuildContext context) {
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _billsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final data = snapshot.data ?? [];
                    final bills = data.map((e) {
                      return KTBillingItem(
                        title: e['title'],
                        description: e['description'] ?? '',
                        amount: (e['amount'] as num).toInt(),
                        dueDate: DateTime.parse(e['due_date']),
                      );
                    }).toList();

                    final hasBills = bills.isNotEmpty;

                    return Column(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
