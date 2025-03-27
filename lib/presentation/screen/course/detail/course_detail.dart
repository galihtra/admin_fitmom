import 'package:admin_fitmom/core/utils/my_color.dart';
import 'package:admin_fitmom/presentation/screen/lesson/edit/edit_lesson_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/course/course_service.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../lesson/add/add_lesson.dart';
import '../../lesson/detail/lesson_detail_screen.dart';
import '../add_member/add_member_screen.dart';
import '../edit/edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  CourseDetailScreen({required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService _courseService = CourseService();
  final LessonService _lessonService = LessonService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<Lesson> lessons = []; // Daftar lesson

  void _deleteCourse(BuildContext context) async {
    bool confirmDelete = await _showDeleteConfirmation(context);
    if (confirmDelete) {
      await _courseService.deleteCourse(widget.course.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.course.name} deleted successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Kelas'),
            content:
                Text('Kamu yakin ingin hapus kelas ${widget.course.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteLesson(BuildContext context, Lesson lesson) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Lesson'),
            content: Text('Kamu yakin ingin hapus Latihan ${lesson.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      await _lessonService.deleteLesson(widget.course.id, lesson.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson ${lesson.name} deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCourseScreen(course: widget.course),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteCourse(context), // Trigger delete course
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.course.image.isNotEmpty
                ? Image.network(widget.course.image,
                    width: double.infinity, height: 200, fit: BoxFit.cover)
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child:
                        Icon(Icons.image, size: 100, color: Colors.grey[600])),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Latihan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<List<Lesson>>(
              stream: _lessonService.getLessons(widget.course.id, userId),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading lessons'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                lessons = snapshot.data!;
                lessons.sort(
                    (a, b) => a.index.compareTo(b.index)); // Sort by index

                return ReorderableListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) async {
                    setState(() {
                      if (newIndex > oldIndex)
                        newIndex -=
                            1; // Adjust newIndex untuk menghindari pergeseran index
                      final movedLesson = lessons.removeAt(oldIndex);
                      lessons.insert(newIndex, movedLesson);
                    });

                    // Update semua index lesson di Firestore dengan batch update
                    final batch = FirebaseFirestore.instance.batch();
                    for (int i = 0; i < lessons.length; i++) {
                      if (lessons[i].index != i) {
                        // Update hanya jika index berubah
                        lessons[i].index = i;
                        final docRef = FirebaseFirestore.instance
                            .collection('courses')
                            .doc(widget.course.id)
                            .collection('lessons')
                            .doc(lessons[i].id);
                        batch.update(docRef, {'index': i});
                      }
                    }
                    await batch
                        .commit(); // Simpan perubahan dengan batch update
                  },
                  children: lessons.map((lesson) {
                    return Card(
                      key: ValueKey(
                          lesson.id), // Key unik untuk mendukung drag-and-drop
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: lesson.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  lesson.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.image,
                                    size: 40, color: Colors.grey[600]),
                              ),
                        title: Text(lesson.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          lesson.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLesson(context, lesson),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: MyColor.secondaryColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditLessonScreen(lesson: lesson),
                                  ),
                                );
                              },
                            ),
                          ],
                        ), // Ikon drag-and-drop
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LessonDetailScreen(lesson: lesson),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddLessonScreen(courseId: widget.course.id),
                      ),
                    );
                  },
                  heroTag: 'addLesson',
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMemberScreen(courseId: widget.course.id),
                      ),
                    );
                  },
                  heroTag: 'otherAction',
                  child: Icon(Icons.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
