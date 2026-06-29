import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Handles all Firestore operations for Products
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Add a new product to Firestore
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).add(product.toMap());
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  /// Fetch paginated product snapshots for a specific user
  Future<QuerySnapshot> getProductSnapshots({
    required String userId,
    int limit = 6,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // If we have a cursor, start after it (pagination)
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return await query.get();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  /// Update an existing product in Firestore
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(productId).update(data);
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  /// Delete a product document from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }
}