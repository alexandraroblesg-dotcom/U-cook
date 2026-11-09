import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/expenses_repository.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/preferences_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesNotifierProvider);
    final expenses = ref.watch(expensesNotifierProvider);
    final plannedFood = ref.watch(plannedFoodTodayProvider);

    final totalSpent = expenses.fold(0, (sum, e) => sum + e.amountCop);
    final remainingCop = (prefs.budgetCop - totalSpent).clamp(0, prefs.budgetCop);
    final spentRatio = prefs.budgetCop > 0
        ? (totalSpent / prefs.budgetCop).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'U-Cook',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '¡Hola, ${prefs.name}!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.night,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.night),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sin notificaciones pendientes. ¡Todo en orden!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué necesitas resolver hoy?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Tarjeta Principal: Planear comida / Que vas a comer hoy
              _buildPlanMealCard(context, ref, plannedFood),

              const SizedBox(height: 16),

              // Atajos directos a tareas frecuentes (Historial & Escaner)
              const Text(
                'Accesos directos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.night,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildShortcutCard(
                      context: context,
                      title: 'Historial',
                      subtitle: 'Revisa tus gastos',
                      icon: Icons.receipt_long_outlined,
                      accentColor: AppColors.yellow,
                      onTap: () => context.go('/expenses'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShortcutCard(
                      context: context,
                      title: 'Escáner',
                      subtitle: 'Analiza nutrición',
                      icon: Icons.qr_code_scanner_rounded,
                      accentColor: AppColors.coral,
                      onTap: () => context.push('/scanner'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Tarjeta de Presupuesto Disponible
              _buildBudgetCard(
                context: context,
                frequency: prefs.groceryFrequency,
                remainingCop: remainingCop,
                totalSpent: totalSpent,
                ratio: spentRatio,
                budgetCop: prefs.budgetCop,
                onTap: () => context.go('/expenses'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanMealCard(BuildContext context, WidgetRef ref, dynamic plannedFood) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                plannedFood != null ? 'Menú planificado para hoy' : '¿Qué vas a comer hoy?',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plannedFood != null
                ? '${plannedFood.name} (${plannedFood.prepTimeMinutes} min)'
                : 'Encuentra ideas rápidas ajustadas a tus compras de la semana.',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFFF1F5EE),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.night,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/food'),
              child: Text(
                plannedFood != null ? 'Ver receta y detalles' : 'Planear menú',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.night, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.night,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required BuildContext context,
    required String frequency,
    required int remainingCop,
    required int totalSpent,
    required double ratio,
    required int budgetCop,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presupuesto $frequency',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  CurrencyFormatter.formatCOP(remainingCop),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.night,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'disponible',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppColors.cream,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ratio > 0.85 ? AppColors.coral : AppColors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastado: ${CurrencyFormatter.formatCOP(totalSpent)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                Text(
                  'Límite: ${CurrencyFormatter.formatCOP(budgetCop)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
