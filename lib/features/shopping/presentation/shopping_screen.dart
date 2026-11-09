import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/shopping_item.dart';
import '../../../data/repositories/shopping_repository.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    String unit = 'unidad';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar a la lista de compras',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.night,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Producto (ej. Huevos, Leche, Plátano)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cantidad'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: ['unidad', 'g', 'kg', 'bolsa', 'lata', 'paquete']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) unit = val;
                        },
                        decoration: const InputDecoration(labelText: 'Unidad'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final qty = double.tryParse(qtyController.text) ?? 1.0;
                        ref.read(shoppingNotifierProvider.notifier).addItem(
                              name: name,
                              quantity: qty,
                              unit: unit,
                            );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Agregar a la lista'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(shoppingNotifierProvider);
    final pendingItems = allItems.where((i) => !i.isDone).toList();
    final doneItems = allItems.where((i) => i.isDone).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Mis Compras'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.green,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.green,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: 'Todos (${allItems.length})'),
            Tab(text: 'Pendientes (${pendingItems.length})'),
            Tab(text: 'Comprados (${doneItems.length})'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildItemList(allItems, 'No tienes productos en tu lista.'),
            _buildItemList(pendingItems, '¡No tienes productos pendientes!'),
            _buildItemList(doneItems, 'Aún no has marcado productos como comprados.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.night,
        foregroundColor: Colors.white,
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
      ),
    );
  }

  Widget _buildItemList(List<ShoppingItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.tagBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega lo que necesitas tocar abajo o enviando faltantes desde una receta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Dismissible(
          key: ValueKey(item.id ?? item.name + index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.coral,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) async {
            final messenger = ScaffoldMessenger.of(context);
            final deleted =
                await ref.read(shoppingNotifierProvider.notifier).deleteItem(item);
            if (!mounted || deleted == null) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text('${item.name} eliminado.'),
                action: SnackBarAction(
                  label: 'Deshacer',
                  onPressed: () {
                    ref.read(shoppingNotifierProvider.notifier).addItem(
                          name: deleted.name,
                          quantity: deleted.quantity,
                          unit: deleted.unit,
                          sourceFoodId: deleted.sourceFoodId,
                        );
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isDone ? AppColors.cardBorder : AppColors.green.withValues(alpha: 0.3),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: InkWell(
                onTap: () {
                  ref.read(shoppingNotifierProvider.notifier).toggleDone(item);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.isDone ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.isDone ? AppColors.green : AppColors.muted,
                      width: 1.5,
                    ),
                  ),
                  child: item.isDone
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  color: item.isDone ? AppColors.muted : AppColors.night,
                ),
              ),
              trailing: Text(
                '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
