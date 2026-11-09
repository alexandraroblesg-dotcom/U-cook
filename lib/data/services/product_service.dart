import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_scan.dart';

class ProductService {
  final Map<String, ProductScan> _cache = {};

  Future<ProductScan?> findByBarcode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return null;

    if (_cache.containsKey(cleanCode)) {
      return _cache[cleanCode];
    }

    try {
      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$cleanCode.json',
        {'fields': 'product_name,brands,image_url,nutriments,quantity'},
      );

      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'U-Cook-App/1.0 (uninorte.edu.co student-project)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1 || data['product'] == null) {
        return null;
      }

      final product = ProductScan.fromOpenFoodFacts(
        data['product'] as Map<String, dynamic>,
        cleanCode,
      );

      _cache[cleanCode] = product;
      return product;
    } catch (e) {
      // Si no hay conexion o la peticion falla, devolvemos null para mostrar estado honesto
      return null;
    }
  }
}
