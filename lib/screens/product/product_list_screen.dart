import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import '../auth/change_password_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _productService = ProductService();
  final _authService = AuthService();

  List<ProductModel> _products = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Load products with pagination
  Future<void> _loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _products = [];
        _lastDocument = null;
        _hasMore = true;
      }
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _productService.getProductSnapshots(
        userId: userId,
        limit: _pageSize,
        lastDocument: refresh ? null : _lastDocument,
      );

      final newProducts = snapshot.docs
          .map((doc) =>
              ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      setState(() {
        _products.addAll(newProducts);
        _lastDocument =
            snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDocument;
        _hasMore = newProducts.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handle logout with confirmation dialog
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          // Change password button
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: 'Change Password',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      // FAB to add a new product
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          _loadProducts(refresh: true);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: RefreshIndicator(
        onRefresh: () => _loadProducts(refresh: true),
        child: _products.isEmpty && !_isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 72, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No products yet. Add one!',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : Column(
                children: [
                  // Product grid
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                MediaQuery.of(context).size.width > 600
                                    ? 0.75
                                    : 0.9,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: _products[index],
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                        product: _products[index]),
                                  ),
                                );
                                _loadProducts(refresh: true);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Pagination controls
                  if (_hasMore || _isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.expand_more),
                              label: const Text('Load More'),
                            ),
                    ),
                ],
              ),
      ),
    );
  }
}
