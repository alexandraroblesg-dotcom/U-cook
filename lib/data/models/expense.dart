class Expense {
  final int? id;
  final int amountCop;
  final String category; // 'Alimentación' u 'Otro'
  final String note;
  final DateTime spentOn;

  const Expense({
    this.id,
    required this.amountCop,
    this.category = 'Alimentación',
    this.note = '',
    required this.spentOn,
  });

  Expense copyWith({
    int? id,
    int? amountCop,
    String? category,
    String? note,
    DateTime? spentOn,
  }) {
    return Expense(
      id: id ?? this.id,
      amountCop: amountCop ?? this.amountCop,
      category: category ?? this.category,
      note: note ?? this.note,
      spentOn: spentOn ?? this.spentOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount_cop': amountCop,
      'category': category,
      'note': note,
      'spent_on': spentOn.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amountCop: (map['amount_cop'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? 'Alimentación',
      note: map['note'] as String? ?? '',
      spentOn: DateTime.tryParse(map['spent_on'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
