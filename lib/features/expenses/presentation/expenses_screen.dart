import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/expenses_repository.dart';
import '../../../data/repositories/preferences_repository.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  void _showAddExpenseModal() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'Alimentación';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      'Registrar nuevo gasto',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.night,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.night,
                      ),
                      decoration: const InputDecoration(
                        labelText: '¿Cuánto gastaste?',
                        prefixText: r'$ ',
                        hintText: '15000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Categoría',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.night),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Alimentación', 'Otro'].map((cat) {
                        final isSelected = category == cat;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.green : Colors.white,
                                foregroundColor: isSelected ? Colors.white : AppColors.night,
                                side: BorderSide(
                                  color: isSelected ? AppColors.green : AppColors.cardBorder,
                                ),
                              ),
                              onPressed: () => setModalState(() => category = cat),
                              child: Text(cat),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Nota opcional (ej. Almuerzo cafetería, D1)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = CurrencyFormatter.parseCOP(amountController.text);
                          if (amount > 0) {
                            ref.read(expensesNotifierProvider.notifier).addExpense(
                                  amountCop: amount,
                                  category: category,
                                  note: noteController.text.trim(),
                                );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Guardar gasto'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditBudgetModal(int currentBudget) {
    final controller = TextEditingController(text: currentBudget.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajustar presupuesto'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto en COP',
              prefixText: r'$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget = CurrencyFormatter.parseCOP(controller.text);
                if (newBudget > 0) {
                  ref.read(preferencesNotifierProvider.notifier).setBudget(newBudget);
                  Navigator.pop(context);
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesNotifierProvider);
    final expenses = ref.watch(expensesNotifierProvider);

    final totalSpent = expenses.fold(0, (sum, e) => sum + e.amountCop);
    final remainingCop = prefs.budgetCop - totalSpent;
    final ratio = prefs.budgetCop > 0
        ? (totalSpent / prefs.budgetCop).clamp(0.0, 1.0)
        : 0.0;
    final isExceeded = remainingCop < 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Gastos y Presupuesto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Ajustar presupuesto',
            onPressed: () => _showEditBudgetModal(prefs.budgetCop),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Resumen de Presupuesto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Presupuesto ${prefs.groceryFrequency}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _showEditBudgetModal(prefs.budgetCop),
                        icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.green),
                        label: const Text('Editar', style: TextStyle(fontSize: 12, color: AppColors.green)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isExceeded
                        ? 'Has superado el presupuesto por ${CurrencyFormatter.formatCOP(remainingCop.abs())}'
                        : '${CurrencyFormatter.formatCOP(remainingCop)} disponible',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isExceeded ? AppColors.coral : AppColors.night,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      backgroundColor: AppColors.cream,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isExceeded
                            ? AppColors.coral
                            : (ratio > 0.8 ? AppColors.yellow : AppColors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gastado: ${CurrencyFormatter.formatCOP(totalSpent)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                      Text(
                        'Meta: ${CurrencyFormatter.formatCOP(prefs.budgetCop)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.night),
                      ),
                    ],
                  ),
                  if (isExceeded) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: AppColors.coral),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El presupuesto se agotó para este periodo. Puedes ajustar el monto o compensar en los próximos días.',
                              style: TextStyle(fontSize: 12, color: AppColors.night),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Registro rápido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.night,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _showAddExpenseModal,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Registrar un gasto'),
              ),
            ),

            const SizedBox(height: 24),

            // Movimientos recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de movimientos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.night,
                  ),
                ),
                Text(
                  '${expenses.length} registro(s)',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (expenses.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Center(
                  child: Text(
                    'No has registrado gastos aún en este periodo.\nToca "Registrar un gasto" para llevar el control.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 13.5),
                  ),
                ),
              )
            else
              ...expenses.map((expense) => _buildExpenseItem(expense)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final dateFormat = DateFormat('dd MMM, h:mm a', 'es_CO');
    final formattedDate = dateFormat.format(expense.spentOn);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: expense.category == 'Alimentación'
              ? AppColors.green.withValues(alpha: 0.15)
              : AppColors.yellow.withValues(alpha: 0.2),
          child: Icon(
            expense.category == 'Alimentación'
                ? Icons.restaurant
                : Icons.account_balance_wallet_outlined,
            color: AppColors.night,
            size: 20,
          ),
        ),
        title: Text(
          CurrencyFormatter.formatCOP(expense.amountCop),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.night,
          ),
        ),
        subtitle: Text(
          expense.note.isNotEmpty
              ? '${expense.category} · ${expense.note}\n$formattedDate'
              : '${expense.category} · $formattedDate',
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
          onPressed: () {
            if (expense.id != null) {
              ref.read(expensesNotifierProvider.notifier).deleteExpense(expense.id!);
            }
          },
        ),
      ),
    );
  }
}
