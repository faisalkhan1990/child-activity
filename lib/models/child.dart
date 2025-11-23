class Child {
  final String id;
  final String name;
  final String age;
  final String parentId;
  final DateTime dateAdded;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'parentId': parentId,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as String,
      parentId: json['parentId'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );
  }
}
