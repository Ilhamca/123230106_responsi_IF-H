import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/controllers.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cart Detail', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value, textAlign: TextAlign.center),
          );
        }
        final article = controller.article.value;
        if (article == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('PRODUCT', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(article.formattedPrice, style: const TextStyle(color: Color(0xFF6C63FF))),
                    const SizedBox(height: 4),
                    Text(article.formattedDate, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(article.summary.isNotEmpty ? article.summary : 'No description available.'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}