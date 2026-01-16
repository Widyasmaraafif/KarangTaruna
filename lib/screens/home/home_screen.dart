import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/buttons/button_fitur.dart';
import 'package:karang_taruna/commons/widgets/containers/post_container.dart';
import 'package:karang_taruna/commons/widgets/texts/section_heading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderHome(),
              NewsHome(),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    KTSectionHeading(
                      title: "Artikel Terbaru",
                      onPressed: () {},
                    ),
                    SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 9 / 11,
                      children: [],
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

class NewsHome extends StatelessWidget {
  const NewsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTSectionHeading(title: "Berita Terbaru", onPressed: () {}),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 9 / 11,
            children: [
              KTPostContainer(
                imageUrl: "https://picsum.photos/400/300",
                title: "Halo Dunia",
                author: "Ketua",
                createdAt: DateTime(2025, 1, 15),
                content:
                    'lorem ipsum dolor sit amet consectetur adipiscing elit. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                category: 'News',
              ),
              KTPostContainer(
                imageUrl: "https://picsum.photos/400/300",
                title: "Halo Dunia",
                author: "Ketua",
                createdAt: DateTime(2025, 1, 15),
                content:
                    'lorem ipsum dolor sit amet consectetur adipiscing elit. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                category: 'News',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 20),
      decoration: BoxDecoration(
        color: Color(0xff79CDB0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Welcome Back!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
              KTButtonFitur(
                icon: Icons.people,
                label: "Pengurus",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
