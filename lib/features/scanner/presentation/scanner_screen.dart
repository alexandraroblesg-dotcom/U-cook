import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_scan.dart';
import '../../../data/repositories/shopping_repository.dart';
import '../../../data/services/product_service.dart';

final productService = ProductService();

enum ScannerState { reading, loading, found, notFound }

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  ScannerState _state = ScannerState.reading;
  ProductScan? _scannedProduct;
  String? _lastBarcode;
  String? _errorMessage;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_state != ScannerState.reading) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    setState(() {
      _state = ScannerState.loading;
      _lastBarcode = code;
      _errorMessage = null;
    });

    _cameraController.stop();

    final product = await productService.findByBarcode(code);

    if (mounted) {
      if (product != null) {
        setState(() {
          _scannedProduct = product;
          _state = ScannerState.found;
        });
      } else {
        setState(() {
          _scannedProduct = null;
          _state = ScannerState.notFound;
          _errorMessage =
              'El código de barras "$code" no se encontró en la base de datos abierta de Open Food Facts o hubo un problema de conexión.';
        });
      }
    }
  }

  void _restartScanning() {
    setState(() {
      _state = ScannerState.reading;
      _scannedProduct = null;
      _lastBarcode = null;
      _errorMessage = null;
    });
    _cameraController.start();
  }

  void _addProductToShopping(ProductScan product) {
    ref.read(shoppingNotifierProvider.notifier).addItem(
          name: '${product.name} (${product.brand})',
          quantity: 1,
          unit: 'unidad',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        content: Text('${product.name} agregado a tu lista de compras.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Escáner Nutricional',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        actions: [
          if (_state == ScannerState.reading)
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => _cameraController.toggleTorch(),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Visor de Cámara
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Marco de lectura centrado cuando lee
          if (_state == ScannerState.reading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 260,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.yellow, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Apunta al código de barras del producto',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Cargando consulta
          if (_state == ScannerState.loading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.green),
                      const SizedBox(height: 16),
                      Text(
                        'Consultando código $_lastBarcode...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Buscando en Open Food Facts',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Producto Encontrado (Modal Bottom Sheet / Card)
          if (_state == ScannerState.found && _scannedProduct != null)
            _buildProductFoundCard(_scannedProduct!),

          // Producto No Encontrado
          if (_state == ScannerState.notFound)
            _buildNotFoundCard(),
        ],
      ),
    );
  }

  Widget _buildProductFoundCard(ProductScan product) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.night,
                        ),
                      ),
                      Text(
                        product.brand,
                        style: const TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                      Text(
                        'Porción: ${product.servingSize}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _restartScanning,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tarjetas de nutrientes (sin inventar datos)
            Row(
              children: [
                _buildNutrientBadge('Calorías', product.calories != null ? '${product.calories!.round()} kcal' : 'N/D'),
                _buildNutrientBadge('Azúcares', product.sugar != null ? '${product.sugar!.toStringAsFixed(1)}g' : 'N/D'),
                _buildNutrientBadge('Grasas', product.fat != null ? '${product.fat!.toStringAsFixed(1)}g' : 'N/D'),
                _buildNutrientBadge('Sodio', product.sodium != null ? '${(product.sodium! * 1000).round()}mg' : 'N/D'),
              ],
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartScanning,
                    child: const Text('Escanear otro'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addProductToShopping(product);
                      _restartScanning();
                    },
                    child: const Text('+ A Compras'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.coral),
                SizedBox(width: 8),
                Text(
                  'Producto no encontrado',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.night,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'No encontramos información para este código de barras en la base abierta.',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartScanning,
                    child: const Text('Reintentar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.night),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.night,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
