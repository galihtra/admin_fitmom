class Course {
  String id;
  String name;
  String description;
  String image;
  bool isAvailable;
  bool isFinished;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isAvailable,
    required this.isFinished,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      isFinished: map['isFinished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'isAvailable': isAvailable,
      'isFinished': isFinished,
    };
  }
}
