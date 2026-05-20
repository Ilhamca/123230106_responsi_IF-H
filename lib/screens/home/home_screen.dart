import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/controllers.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<MainNavController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6FED),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MyStore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Welcome to MyStore',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse products, manage your cart, and update your profile from one place.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  _ActionCard(
                    title: 'Store',
                    subtitle: 'Open the product catalog and filter by category.',
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFF2F6FED),
                    onTap: () => navController.changePage(0),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Cart',
                    subtitle: 'Review saved products and remove items if needed.',
                    icon: Icons.shopping_cart_rounded,
                    color: const Color(0xFF11A36A),
                    onTap: () => navController.changePage(1),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Profile',
                    subtitle: 'See your username and update your profile photo.',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => navController.changePage(2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6ECF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
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
