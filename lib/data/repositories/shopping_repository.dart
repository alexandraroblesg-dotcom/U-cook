import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food.dart';
import '../models/shopping_item.dart';
import '../services/database_service.dart';

final shoppingNotifierProvider =
    StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>((ref) {
  return ShoppingNotifier();
});

class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingNotifier() : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await DatabaseService.instance.getShoppingItems();
      state = items;
    } catch (_) {
      state = [];
    }
  }

  Future<void> addItem({
    required String name,
    double quantity = 1.0,
    String unit = 'unidad',
    int? sourceFoodId,
  }) async {
    final newItem = ShoppingItem(
      name: name,
      quantity: quantity,
      unit: unit,
      sourceFoodId: sourceFoodId,
    );
    try {
      final id = await DatabaseService.instance.insertShoppingItem(newItem);
      state = [newItem.copyWith(id: id), ...state];
    } catch (_) {
      state = [newItem, ...state];
    }
  }

  Future<void> addIngredientsFromFood(Food food, List<Ingredient> selectedIngredients) async {
    for (final ing in selectedIngredients) {
      await addItem(
        name: ing.name,
        quantity: ing.quantity.toDouble(),
        unit: ing.unit,
        sourceFoodId: food.id,
      );
    }
  }

  Future<void> toggleDone(ShoppingItem item) async {
    final updated = item.copyWith(isDone: !item.isDone);
    try {
      if (item.id != null) {
        await DatabaseService.instance.updateShoppingItem(updated);
      }
    } catch (_) {}

    state = [
      for (final i in state)
        if (i.id == item.id && item.id != null) updated else i,
    ];
  }

  Future<ShoppingItem?> deleteItem(ShoppingItem item) async {
    try {
      if (item.id != null) {
        await DatabaseService.instance.deleteShoppingItem(item.id!);
      }
    } catch (_) {}

    state = state.where((i) => i.id != item.id).toList();
    return item;
  }
}
