import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin_fitmom/core/utils/my_color.dart';

import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/model/lesson/lesson_folder.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../add/add_lesson.dart';
import '../detail/lesson_detail_screen.dart';
import '../edit/edit_lesson_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final String courseId;
  final LessonFolder folder;

  const FolderDetailScreen({
    required this.courseId,
    required this.folder,
  });

  @override
  _FolderDetailScreenState createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final _lessonService = LessonService();
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _deleteLesson(BuildContext context, Lesson lesson) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Lesson'),
            content: Text('Are you sure you want to delete ${lesson.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      await _lessonService.deleteLesson(widget.courseId, lesson.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson ${lesson.name} deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyColor.primaryColor, MyColor.secondaryColor],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: StreamBuilder<List<Lesson>>(
          stream: _lessonService.getLessons(widget.courseId, userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No lessons in this folder',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a new lesson',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final lessons = snapshot.data!
                .where((lesson) => lesson.folderName == widget.folder.name)
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: lessons.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LessonDetailScreen(lesson: lesson),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                                image: lesson.image.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(lesson.image),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: lesson.image.isEmpty
                                  ? Center(
                                      child: Icon(
                                        Icons.fitness_center,
                                        size: 30,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    lesson.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert, color: Colors.grey),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit,
                                          color: MyColor.secondaryColor),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                  value: 'delete',
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditLessonScreen(lesson: lesson),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _deleteLesson(context, lesson);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColor.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLessonScreen(
                courseId: widget.courseId,
                folderName: widget.folder.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
