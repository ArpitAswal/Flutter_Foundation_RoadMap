// =============================================================================
// 🌍 Country Model — GraphQL Serialization Example
// =============================================================================
//
// Models for GraphQL responses operate exactly the same as REST JSON models.
// GraphQL clients still return Dart Maps (`Map<String, dynamic>`) which must
// be parsed into strongly typed objects.
// =============================================================================

class Country {
  final String code;
  final String name;
  final String emoji;
  final String capital;

  const Country({
    required this.code,
    required this.name,
    required this.emoji,
    required this.capital,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      emoji: json['emoji'] as String? ?? '🌍',
      capital: json['capital'] as String? ?? 'Unknown',
    );
  }
}
