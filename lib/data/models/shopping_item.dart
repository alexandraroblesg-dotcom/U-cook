class ShoppingItem {
  final int? id;
  final int listId;
  final String name;
  final double quantity;
  final String unit;
  final bool isDone;
  final int? sourceFoodId;

  const ShoppingItem({
    this.id,
    this.listId = 1,
    required this.name,
    this.quantity = 1.0,
    this.unit = 'unidad',
    this.isDone = false,
    this.sourceFoodId,
  });

  ShoppingItem copyWith({
    int? id,
    int? listId,
    String? name,
    double? quantity,
    String? unit,
    bool? isDone,
    int? sourceFoodId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isDone: isDone ?? this.isDone,
      sourceFoodId: sourceFoodId ?? this.sourceFoodId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'list_id': listId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'is_done': isDone ? 1 : 0,
      'source_food_id': sourceFoodId,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      listId: map['list_id'] as int? ?? 1,
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'unidad',
      isDone: (map['is_done'] == 1 || map['is_done'] == true),
      sourceFoodId: map['source_food_id'] as int?,
    );
  }
}
