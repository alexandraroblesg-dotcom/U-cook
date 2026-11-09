class UserPreferences {
  final String name;
  final String diners;
  final List<String> goals;
  final String groceryFrequency;
  final int budgetCop;
  final bool onboardingDone;

  const UserPreferences({
    this.name = 'Estudiante',
    this.diners = 'Solo para mí',
    this.goals = const [],
    this.groceryFrequency = 'Semanal',
    this.budgetCop = 200000,
    this.onboardingDone = false,
  });

  UserPreferences copyWith({
    String? name,
    String? diners,
    List<String>? goals,
    String? groceryFrequency,
    int? budgetCop,
    bool? onboardingDone,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      diners: diners ?? this.diners,
      goals: goals ?? this.goals,
      groceryFrequency: groceryFrequency ?? this.groceryFrequency,
      budgetCop: budgetCop ?? this.budgetCop,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'diners': diners,
      'goals': goals.join(','),
      'groceryFrequency': groceryFrequency,
      'budgetCop': budgetCop,
      'onboardingDone': onboardingDone ? 1 : 0,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    final rawGoals = map['goals'] as String? ?? '';
    return UserPreferences(
      name: map['name'] as String? ?? 'Estudiante',
      diners: map['diners'] as String? ?? 'Solo para mí',
      goals: rawGoals.isEmpty ? [] : rawGoals.split(','),
      groceryFrequency: map['groceryFrequency'] as String? ?? 'Semanal',
      budgetCop: (map['budgetCop'] as num?)?.toInt() ?? 200000,
      onboardingDone: (map['onboardingDone'] == 1 || map['onboardingDone'] == true),
    );
  }
}
