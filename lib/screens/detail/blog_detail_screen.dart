import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/article.dart';
import '../../services/controllers.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetailController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6FED),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Product Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2F6FED)),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final product = controller.article.value;
        if (product == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 280,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF2F6FED)),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 280,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined, size: 56, color: Colors.grey),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip(label: product.category.isEmpty ? 'Product' : product.category),
                            _InfoChip(label: product.brand.isEmpty ? 'Brand unknown' : product.brand),
                            _InfoChip(label: 'Stock ${product.stock}'),
                            _InfoChip(label: '${product.formattedDiscount} off'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2F6FED),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.summary.isEmpty ? 'No description available.' : product.summary,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Rating', value: product.rating.toStringAsFixed(1)),
                        _DetailRow(label: 'Category', value: product.category.isEmpty ? '-' : product.category),
                        _DetailRow(label: 'Brand', value: product.brand.isEmpty ? '-' : product.brand),
                        _DetailRow(label: 'Stock', value: product.stock.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: controller.toggleCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.inCart.value
                        ? Colors.red.shade600
                        : const Color(0xFF2F6FED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(
                    controller.inCart.value
                        ? Icons.remove_shopping_cart_rounded
                        : Icons.add_shopping_cart_rounded,
                  ),
                  label: Text(
                    controller.inCart.value ? 'Remove from Cart' : 'Add to Cart',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6FED).withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2F6FED),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
