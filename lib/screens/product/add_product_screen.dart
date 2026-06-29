import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _productService = ProductService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Submit the new product form
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final product = ProductModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _categoryController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _productService.addProduct(product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image URL preview
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imageUrlController.text.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.grey),
                          ),
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image preview will appear here',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Image URL field
              CustomTextField(
                controller: _imageUrlController,
                label: 'Image URL (optional)',
                hint: 'https://example.com/image.jpg',
                keyboardType: TextInputType.url,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}), // Refresh preview
                ),
              ),
              const SizedBox(height: 16),

              // Product name
              CustomTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Price
              CustomTextField(
                controller: _priceController,
                label: 'Price',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Price is required';
                  if (double.tryParse(val) == null)
                    return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              CustomTextField(
                controller: _categoryController,
                label: 'Category',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}