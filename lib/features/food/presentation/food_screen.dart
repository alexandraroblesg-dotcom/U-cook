import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/food.dart';
import '../../../data/repositories/food_repository.dart';

class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> {
  int _selectedDayIndex = 2; // Miércoles como ejemplo de media semana
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  final List<String> _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  final List<String> _timeFilters = ['Todos', 'Menos de 15m', '20 a 30m', 'Más de 40m'];

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodNotifierProvider);
    final plannedFood = ref.watch(plannedFoodTodayProvider);

    final filteredFoods = foods.where((food) {
      if (_searchQuery.isNotEmpty &&
          !food.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedFilter == 'Menos de 15m' && food.prepTimeMinutes > 15) {
        return false;
      }
      if (_selectedFilter == '20 a 30m' &&
          (food.prepTimeMinutes < 16 || food.prepTimeMinutes > 30)) {
        return false;
      }
      if (_selectedFilter == 'Más de 40m' && food.prepTimeMinutes < 35) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Comidas y Plan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Selector semanal horizontal
            _buildWeekCalendar(),

            const SizedBox(height: 16),

            // Bloque Menú de hoy (Planificación visible)
            _buildTodayMealCard(plannedFood),

            const SizedBox(height: 20),

            // Buscador de recetas
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Buscar recetas económicas o ingredientes...',
                prefixIcon: Icon(Icons.search, color: AppColors.green),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // Chips de tiempo disponible
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeFilters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.night,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.green,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppColors.green : AppColors.cardBorder,
                      ),
                      onSelected: (val) => setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de recetas
            Text(
              'Recetas sugeridas (${filteredFoods.length})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.night,
              ),
            ),
            const SizedBox(height: 10),

            if (filteredFoods.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Center(
                  child: Text(
                    'No encontramos recetas con ese filtro.\nPrueba seleccionando otro tiempo o borrando la búsqueda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...filteredFoods.map((food) => _buildRecipeCard(food)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isSelected = _selectedDayIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedDayIndex = index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _days[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${20 + index}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.night,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodayMealCard(Food? plannedFood) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellow, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available, color: AppColors.night, size: 20),
              SizedBox(width: 8),
              Text(
                'Menú planificado para hoy',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.night,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (plannedFood != null) ...[
            Text(
              plannedFood.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiempo: ${plannedFood.prepTimeMinutes} min  ·  Porciones: ${plannedFood.portions}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => context.push('/food/detail/${plannedFood.id}'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Ver ingredientes y pasos', style: TextStyle(fontSize: 12.5)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => ref.read(plannedFoodTodayProvider.notifier).state = null,
                  child: const Text('Quitar', style: TextStyle(color: AppColors.coral, fontSize: 12.5)),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Aún no has elegido qué preparar hoy. Selecciona una receta abajo y añádela con un solo toque.',
              style: TextStyle(fontSize: 13, color: AppColors.night),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Food food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: () => context.push('/food/detail/${food.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fastfood_outlined, color: AppColors.green, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.night,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      food.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: food.isFavorite ? AppColors.coral : AppColors.muted,
                    ),
                    onPressed: () =>
                        ref.read(foodNotifierProvider.notifier).toggleFavorite(food.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: AppColors.night),
                        const SizedBox(width: 4),
                        Text(
                          '${food.prepTimeMinutes} min',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${food.portions} porción(es)',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
