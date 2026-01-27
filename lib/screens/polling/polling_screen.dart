import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/pooling_card.dart';

class PollingScreen extends StatelessWidget {
  const PollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KTPoolingCard(
            title: "Kegiatan apa yang kamu pilih minggu ini?",
            options: const [
              KTPoolingOption(label: "Kerja bakti lingkungan", value: 40),
              KTPoolingOption(label: "Pelatihan keterampilan", value: 25),
              KTPoolingOption(label: "Lomba olahraga", value: 35),
            ],
            onOptionTap: (option) {
              // TODO: Implement voting logic
              Get.snackbar(
                'Vote',
                'Kamu memilih ${option.label}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 16),
          KTPoolingCard(
            title: "Lokasi wisata tahunan?",
            options: const [
              KTPoolingOption(label: "Pantai", value: 60),
              KTPoolingOption(label: "Gunung", value: 30),
              KTPoolingOption(label: "Museum", value: 10),
            ],
            onOptionTap: (option) {
              Get.snackbar(
                'Vote',
                'Kamu memilih ${option.label}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
