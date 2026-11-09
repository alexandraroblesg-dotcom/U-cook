class ProductScan {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final double? calories;
  final double? sugar;
  final double? fat;
  final double? sodium;
  final double? fiber;
  final String servingSize;
  final String source;
  final DateTime scanDate;

  const ProductScan({
    required this.barcode,
    required this.name,
    this.brand = '',
    this.imageUrl,
    this.calories,
    this.sugar,
    this.fat,
    this.sodium,
    this.fiber,
    this.servingSize = '100g / 100ml',
    this.source = 'Open Food Facts',
    required this.scanDate,
  });

  factory ProductScan.fromOpenFoodFacts(Map<String, dynamic> json, String code) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    return ProductScan(
      barcode: code,
      name: (json['product_name'] as String?)?.trim().isNotEmpty == true
          ? json['product_name'] as String
          : 'Producto sin nombre',
      brand: json['brands'] as String? ?? 'Marca no especificada',
      imageUrl: json['image_url'] as String?,
      calories: (nutriments['energy-kcal_100g'] as num?)?.toDouble() ??
          (nutriments['energy-kcal'] as num?)?.toDouble(),
      sugar: (nutriments['sugars_100g'] as num?)?.toDouble() ??
          (nutriments['sugars'] as num?)?.toDouble(),
      fat: (nutriments['fat_100g'] as num?)?.toDouble() ??
          (nutriments['fat'] as num?)?.toDouble(),
      sodium: (nutriments['sodium_100g'] as num?)?.toDouble() ??
          (nutriments['sodium'] as num?)?.toDouble(),
      fiber: (nutriments['fiber_100g'] as num?)?.toDouble() ??
          (nutriments['fiber'] as num?)?.toDouble(),
      servingSize: json['quantity'] as String? ?? 'Porción 100g',
      source: 'Open Food Facts (Open Data)',
      scanDate: DateTime.now(),
    );
  }
}
