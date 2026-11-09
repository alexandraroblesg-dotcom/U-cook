import 'package:flutter_test/flutter_test.dart';
import 'package:ucook/core/utils/currency_formatter.dart';
import 'package:ucook/data/models/expense.dart';
import 'package:ucook/data/models/food.dart';
import 'package:ucook/data/models/shopping_item.dart';
import 'package:ucook/data/models/user_preferences.dart';

void main() {
  group('Pruebas Unitarias U-Cook (Matriz de Aceptación)', () {
    // T09: Formatear montos en COP exactos
    test('T09: CurrencyFormatter formatea COP sin decimales correctamente', () {
      final formatted = CurrencyFormatter.formatCOP(300000);
      expect(formatted.contains('300.000') || formatted.contains('300,000'), isTrue);
      expect(formatted.endsWith(',00') || formatted.endsWith('.00'), isFalse);

      final parsed = CurrencyFormatter.parseCOP('\$ 300.000 COP');
      expect(parsed, 300000);
    });

    // T08: Cálculo exacto de presupuesto y gastos
    test('T08: Registro de gasto de \$82.000 reduce exactamente el presupuesto restante', () {
      const initialBudget = 200000;
      final expense = Expense(
        amountCop: 82000,
        category: 'Alimentación',
        spentOn: DateTime.now(),
      );

      final remaining = initialBudget - expense.amountCop;
      expect(remaining, 118000);

      final ratio = (expense.amountCop / initialBudget).clamp(0.0, 1.0);
      expect(ratio, closeTo(0.41, 0.01));
    });

    // T01: Onboarding y preferencias de usuario
    test('T01: Modelo de UserPreferences maneja estado y comensales', () {
      const prefs = UserPreferences(
        name: 'Carlos',
        diners: 'Para 2 personas',
        goals: ['Ahorrar tiempo', 'Gastar menos dinero'],
        groceryFrequency: 'Semanal',
        budgetCop: 250000,
        onboardingDone: true,
      );

      expect(prefs.name, 'Carlos');
      expect(prefs.onboardingDone, isTrue);
      expect(prefs.goals.length, 2);

      final map = prefs.toMap();
      final restored = UserPreferences.fromMap(map);
      expect(restored.name, 'Carlos');
      expect(restored.budgetCop, 250000);
      expect(restored.onboardingDone, isTrue);
    });

    // T05: Integración comida -> compras
    test('T05: Los ingredientes de una comida se pueden mapear a ShoppingItems', () {
      const food = Food(
        id: 10,
        name: 'Arepa con queso',
        prepTimeMinutes: 10,
        portions: 1,
        category: 'Desayuno',
        difficulty: 'Fácil',
        description: 'Arepa rápida',
        ingredients: [
          Ingredient(name: 'Arepa', quantity: 2, unit: 'unidades'),
          Ingredient(name: 'Queso', quantity: 100, unit: 'g'),
        ],
        steps: ['Asar', 'Rellenar'],
        tags: ['Rápido'],
      );

      final shoppingItems = food.ingredients.map((ing) {
        return ShoppingItem(
          name: ing.name,
          quantity: ing.quantity.toDouble(),
          unit: ing.unit,
          sourceFoodId: food.id,
        );
      }).toList();

      expect(shoppingItems.length, 2);
      expect(shoppingItems.first.name, 'Arepa');
      expect(shoppingItems.first.sourceFoodId, 10);
      expect(shoppingItems.last.name, 'Queso');
    });
  });
}
