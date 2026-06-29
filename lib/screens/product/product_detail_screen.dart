import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  /// Show delete confirmation and delete product
  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
            'Are you sure you want to delete this product? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final service = ProductService();
        await service.deleteProduct(product.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Product deleted'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product)),
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteProduct(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              width: double.infinity,
              height: 280,
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 80)),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 80)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Rs. ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category chip
                  Chip(
                    label: Text(product.category),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(product.description,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 16),

                  // Date added
                  Text(
                    'Added: ${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
                    style: const TextStyle(color: Colors.grey),
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
