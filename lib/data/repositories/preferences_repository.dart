import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  return PreferencesNotifier();
});

class PreferencesNotifier extends StateNotifier<UserPreferences> {
  PreferencesNotifier() : super(const UserPreferences()) {
    loadPreferences();
  }

  static const _keyName = 'user_name';
  static const _keyDiners = 'user_diners';
  static const _keyGoals = 'user_goals';
  static const _keyFrequency = 'grocery_frequency';
  static const _keyBudget = 'budget_cop';
  static const _keyDone = 'onboarding_done';

  Future<void> loadPreferences() async {
    try {
      final sp = await SharedPreferences.getInstance();
      state = UserPreferences(
        name: sp.getString(_keyName) ?? 'Estudiante',
        diners: sp.getString(_keyDiners) ?? 'Solo para mí',
        goals: sp.getStringList(_keyGoals) ?? [],
        groceryFrequency: sp.getString(_keyFrequency) ?? 'Semanal',
        budgetCop: sp.getInt(_keyBudget) ?? 200000,
        onboardingDone: sp.getBool(_keyDone) ?? false,
      );
    } catch (_) {}
  }

  Future<void> savePreferences({
    required String name,
    required String diners,
    required List<String> goals,
    required String groceryFrequency,
    required int budgetCop,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyName, name);
    await sp.setString(_keyDiners, diners);
    await sp.setStringList(_keyGoals, goals);
    await sp.setString(_keyFrequency, groceryFrequency);
    await sp.setInt(_keyBudget, budgetCop);
    await sp.setBool(_keyDone, true);

    state = UserPreferences(
      name: name,
      diners: diners,
      goals: goals,
      groceryFrequency: groceryFrequency,
      budgetCop: budgetCop,
      onboardingDone: true,
    );
  }

  Future<void> setBudget(int newBudget) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_keyBudget, newBudget);
    state = state.copyWith(budgetCop: newBudget);
  }
}
