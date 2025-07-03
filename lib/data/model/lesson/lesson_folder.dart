class LessonFolder {
  final String id;
  final String name;

  LessonFolder({required this.id, required this.name});

  factory LessonFolder.fromMap(Map<String, dynamic> map, String id) {
    return LessonFolder(
      id: id,
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
