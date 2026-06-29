import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_text_field.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageUrlController;
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing product data
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _categoryController =
        TextEditingController(text: widget.product.category);
    _imageUrlController =
        TextEditingController(text: widget.product.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Submit the edit form
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _productService.updateProduct(widget.product.id, {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _categoryController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product updated successfully!'),
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
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
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
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
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

              CustomTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                label: 'Price',
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

              CustomTextField(
                controller: _categoryController,
                label: 'Category',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}