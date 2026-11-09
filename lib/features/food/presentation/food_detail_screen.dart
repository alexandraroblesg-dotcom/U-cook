import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/food.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/shopping_repository.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final int foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  final Set<int> _missingIngredientIndices = {};

  @override
  void initState() {
    super.initState();
    // Por defecto, marcamos todos como faltantes para facilitar agregarlos a la lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final food = ref.read(foodNotifierProvider.notifier).getById(widget.foodId);
      if (food != null) {
        setState(() {
          for (int i = 0; i < food.ingredients.length; i++) {
            _missingIngredientIndices.add(i);
          }
        });
      }
    });
  }

  void _sendToShopping(Food food) async {
    final selectedIngredients = _missingIngredientIndices
        .map((index) => food.ingredients[index])
        .toList();

    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay ingredientes seleccionados para enviar a compras.'),
        ),
      );
      return;
    }

    await ref
        .read(shoppingNotifierProvider.notifier)
        .addIngredientsFromFood(food, selectedIngredients);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.green,
          content: Text('${selectedIngredients.length} ingredientes agregados a Compras.'),
          action: SnackBarAction(
            label: 'Ver lista',
            textColor: AppColors.yellow,
            onPressed: () => context.go('/shopping'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodNotifierProvider);
    final food = foods.where((f) => f.id == widget.foodId).firstOrNull;

    if (food == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Receta no encontrada.')),
      );
    }

    final isPlanned = ref.watch(plannedFoodTodayProvider)?.id == food.id;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(food.name),
        actions: [
          IconButton(
            icon: Icon(
              food.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: food.isFavorite ? AppColors.coral : AppColors.night,
            ),
            onPressed: () =>
                ref.read(foodNotifierProvider.notifier).toggleFavorite(food.id),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Resumen de tiempo y porciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.night,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChipMetric(Icons.schedule, '${food.prepTimeMinutes} min', 'Preparación'),
                      _buildChipMetric(Icons.people_outline, '${food.portions} pers.', 'Porciones'),
                      _buildChipMetric(Icons.speed, food.difficulty, 'Dificultad'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPlanned ? AppColors.muted : AppColors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (isPlanned) {
                          ref.read(plannedFoodTodayProvider.notifier).state = null;
                        } else {
                          ref.read(plannedFoodTodayProvider.notifier).state = food;
                        }
                      },
                      icon: Icon(isPlanned ? Icons.check : Icons.today),
                      label: Text(isPlanned ? 'Planificada para hoy' : 'Planificar para hoy'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sección de Ingredientes con selección
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredientes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.night,
                  ),
                ),
                Text(
                  'Marca lo que te falte',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: List.generate(food.ingredients.length, (index) {
                  final ing = food.ingredients[index];
                  final isChecked = _missingIngredientIndices.contains(index);

                  return CheckboxListTile(
                    activeColor: AppColors.green,
                    value: isChecked,
                    title: Text(
                      ing.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.night,
                      ),
                    ),
                    subtitle: Text(
                      '${ing.quantity} ${ing.unit}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _missingIngredientIndices.add(index);
                        } else {
                          _missingIngredientIndices.remove(index);
                        }
                      });
                    },
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Clave: Enviar faltantes a Compras
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.night,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _sendToShopping(food),
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: Text(
                  'Enviar faltantes a Compras (${_missingIngredientIndices.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instrucciones paso a paso
            const Text(
              'Preparación paso a paso',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.night,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: List.generate(food.steps.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.green,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            food.steps[index],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.night,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChipMetric(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.green),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.night),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
