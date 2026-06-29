/// Model class representing a Product in Firestore
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl; // User pastes an image URL
  final String userId; // Owner of the product
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  /// Convert Firestore document snapshot to ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convert ProductModel to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}