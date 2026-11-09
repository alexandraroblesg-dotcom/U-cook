import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

final expensesNotifierProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final items = await DatabaseService.instance.getExpenses();
      state = items;
    } catch (_) {
      state = [];
    }
  }

  Future<void> addExpense({
    required int amountCop,
    required String category,
    String note = '',
    DateTime? date,
  }) async {
    final newExpense = Expense(
      amountCop: amountCop,
      category: category,
      note: note,
      spentOn: date ?? DateTime.now(),
    );

    try {
      final id = await DatabaseService.instance.insertExpense(newExpense);
      state = [newExpense.copyWith(id: id), ...state];
    } catch (_) {
      state = [newExpense, ...state];
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DatabaseService.instance.deleteExpense(id);
    } catch (_) {}
    state = state.where((e) => e.id != id).toList();
  }

  int get totalSpent =>
      state.fold(0, (sum, expense) => sum + expense.amountCop);

  int get totalFoodSpent => state
      .where((e) => e.category == 'Alimentación')
      .fold(0, (sum, expense) => sum + expense.amountCop);
}
