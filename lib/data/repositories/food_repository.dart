import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food.dart';

final foodNotifierProvider =
    StateNotifierProvider<FoodNotifier, List<Food>>((ref) {
  return FoodNotifier();
});

final plannedFoodTodayProvider = StateProvider<Food?>((ref) => null);

class FoodNotifier extends StateNotifier<List<Food>> {
  FoodNotifier() : super([]) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/recipes.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      state = list.map((e) => Food.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Si no carga el asset, mantenemos lista minima de respaldo
      state = [
        const Food(
          id: 1,
          name: "Arepa con Huevo y Queso Costeño",
          prepTimeMinutes: 12,
          portions: 1,
          category: "Desayuno / Cena",
          difficulty: "Fácil",
          description: "Clásico caribeño rápido y rendidor.",
          ingredients: [
            Ingredient(name: "Arepa blanca", quantity: 1, unit: "unidad"),
            Ingredient(name: "Huevo", quantity: 1, unit: "unidad"),
            Ingredient(name: "Queso costeño", quantity: 50, unit: "g"),
          ],
          steps: [
            "Asa la arepa en sartén caliente.",
            "Fríe el huevo.",
            "Rellena con huevo y queso costeño."
          ],
          tags: ["Rápido (<15m)", "Desayuno"],
        ),
      ];
    }
  }

  void toggleFavorite(int foodId) {
    state = [
      for (final food in state)
        if (food.id == foodId)
          food.copyWith(isFavorite: !food.isFavorite)
        else
          food,
    ];
  }

  Food? getById(int id) {
    try {
      return state.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }
}
