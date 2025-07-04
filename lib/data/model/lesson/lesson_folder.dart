class LessonFolder {
  final String id;
  final String name;
  final String? parentFolderName;

  LessonFolder({
    required this.id,
    required this.name,
    this.parentFolderName,
  });

  factory LessonFolder.fromMap(Map<String, dynamic> map, String id) {
    return LessonFolder(
      id: id,
      name: map['name'] ?? '',
      parentFolderName: map['parent_folder_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parent_folder_name': parentFolderName,
    };
  }
}
