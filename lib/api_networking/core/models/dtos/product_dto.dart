// =============================================================================
// 📦 Product DTO (Data Transfer Object)
// =============================================================================
//
// WHY DTO?
//   This exact structure matches the backend JSON contract.
//   It might contain fields we don't care about, or snake_case variables.
//   We parse it exactly as the API gives it to us.
// =============================================================================

class ProductDto {
  final int? id;
  final String? title;
  final String? description;
  final num? price;
  final String? thumbnail;

  const ProductDto({
    this.id,
    this.title,
    this.description,
    this.price,
    this.thumbnail,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: json['price'] as num?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
    };
  }
}
