class Recipe {
  final int? id;
  final String name;
  final String? description;

  Recipe({this.id, required this.name, this.description});

  Recipe copyWith({int? id, String? name, String? description}) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
