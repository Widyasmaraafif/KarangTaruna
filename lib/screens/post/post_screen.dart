import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/containers/aspiration_card.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    const int postsCount = 5;

    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...List.generate(postsCount, (index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: KTAspirationCard(
                    author: 'User ${index + 1}',
                    content:
                        'Ini adalah aspirasi ke-${index + 1} yang akan nanti diambil dari Supabase.',
                    createdAt: DateTime(2026, 1, 10 - index),
                    status: index.isEven ? 'Sedang Ditinjau' : 'Selesai',
                    onTap: () {},
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
