// =============================================================================
// 🏭 Product Domain Model
// =============================================================================
//
// WHY DOMAIN MODEL?
//   This is the clean, business-friendly structure our UI uses.
//   No nullables (we provide defaults in the mapper), clean naming.
//   If the API changes `title` to `product_name`, the UI doesn't break,
//   only the Repository mapper changes!
// =============================================================================

class Product {
  final int id;
  final String name; // Named 'name' instead of 'title' to prove DTO separation
  final String description;
  final double price;
  final String imageUrl; // Named 'imageUrl' instead of 'thumbnail'

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: \$$price)';
  }
}
