import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/article.dart';
import '../../services/controllers.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchProducts(
              category: controller.selectedCategory.value.isEmpty
                  ? null
                  : controller.selectedCategory.value,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Obx(() {
              final categories = controller.categories;
              final selected = controller.selectedCategory.value.isEmpty
                  ? 'All'
                  : controller.selectedCategory.value;

              final items = <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(value: 'All', child: Text('All')),
                ...categories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category.slug,
                    child: Text(category.name),
                  ),
                ),
              ];

              return Row(
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: items.any((item) => item.value == selected)
                          ? selected
                          : 'All',
                      items: items,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        final category = (value == null || value == 'All')
                            ? null
                            : value;
                        controller.fetchProducts(category: category);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2F6FED)),
                );
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: () => controller.fetchProducts(
                    category: controller.selectedCategory.value.isEmpty
                        ? null
                        : controller.selectedCategory.value,
                  ),
                );
              }
              if (controller.products.isEmpty) {
                return const _EmptyState(
                  title: 'No products found',
                  subtitle: 'Try another category or refresh the page.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchProducts(
                  category: controller.selectedCategory.value.isEmpty
                      ? null
                      : controller.selectedCategory.value,
                ),
                color: const Color(0xFF2F6FED),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(product: controller.products[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Article product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Get.toNamed('/detail', arguments: {'product': product});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6ECF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2F6FED),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F6FED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6FED),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
