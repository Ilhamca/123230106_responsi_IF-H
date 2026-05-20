// ============================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/controllers.dart';
import '../list/blog_screen.dart';
import '../list/report_screen.dart';
import '../list/news_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<MainNavController>();

    final List<Widget> tabs = [
      const BlogScreen(key: ValueKey('store')),
      const ReportScreen(key: ValueKey('cart')),
      const ProfilePage(key: ValueKey('profile')),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: navController.currentIndex.value,
            children: tabs,
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF2F6FED),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            backgroundColor: Colors.white,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                activeIcon: Icon(Icons.storefront_rounded),
                label: 'Store',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart_rounded),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}
