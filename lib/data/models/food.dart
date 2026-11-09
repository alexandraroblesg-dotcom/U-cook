class Ingredient {
  final String name;
  final num quantity;
  final String unit;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?) ?? 1,
      unit: map['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class Food {
  final int id;
  final String name;
  final int prepTimeMinutes;
  final int portions;
  final String category;
  final String difficulty;
  final String description;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> tags;
  final bool isFavorite;

  const Food({
    required this.id,
    required this.name,
    required this.prepTimeMinutes,
    required this.portions,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.tags,
    this.isFavorite = false,
  });

  Food copyWith({
    int? id,
    String? name,
    int? prepTimeMinutes,
    int? portions,
    String? category,
    String? difficulty,
    String? description,
    List<Ingredient>? ingredients,
    List<String>? steps,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      portions: portions ?? this.portions,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    final rawIngredients = (map['ingredients'] as List<dynamic>? ?? []);
    final rawSteps = (map['steps'] as List<dynamic>? ?? []);
    final rawTags = (map['tags'] as List<dynamic>? ?? []);

    return Food(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      prepTimeMinutes: (map['prep_time_minutes'] as num?)?.toInt() ?? 15,
      portions: (map['portions'] as num?)?.toInt() ?? 1,
      category: map['category'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'Fácil',
      description: map['description'] as String? ?? '',
      ingredients: rawIngredients.map((i) => Ingredient.fromMap(i as Map<String, dynamic>)).toList(),
      steps: rawSteps.map((s) => s.toString()).toList(),
      tags: rawTags.map((t) => t.toString()).toList(),
      isFavorite: map['isFavorite'] == true,
    );
  }
}
