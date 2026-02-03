import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/event/event_screen.dart';
import 'package:karang_taruna/screens/finance/finance_screen.dart';
import 'package:karang_taruna/screens/home/home_screen.dart';
import 'package:karang_taruna/screens/post/post_screen.dart';
import 'package:karang_taruna/screens/profile/profile_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    Get.put(
      DataController(),
    ); // Initialize DataController to fetch data in background

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.selectedIndex.value = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF00BA9B),
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Keuangan Pribadi',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const PostScreen(),
    const EventScreen(),
    const FinanceScreen(),
    const ProfileScreen(),
  ];
}
