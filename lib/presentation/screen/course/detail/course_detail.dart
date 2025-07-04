import 'package:admin_fitmom/core/utils/my_color.dart';
import 'package:admin_fitmom/presentation/screen/lesson/edit/edit_lesson_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/model/lesson/lesson_folder.dart';
import '../../../../data/services/course/course_service.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../lesson/add/add_lesson.dart';
import '../../lesson/detail/lesson_detail_screen.dart';
import '../../lesson/folder/folder_detail_screen.dart';
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
  List<Lesson> lessons = [];

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

  Future<String?> _showFolderInputDialog(BuildContext context) async {
    String folderName = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nama Folder Baru'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan nama folder',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) => folderName = value,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () => Navigator.of(context).pop(folderName),
            ),
          ],
        );
      },
    );
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
            onPressed: () => _deleteCourse(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: widget.course.image.isNotEmpty
                    ? Image.network(
                        widget.course.image,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Folders Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Folder Latihan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: MyColor.primaryColor),
                        onPressed: () async {
                          String? folderName =
                              await _showFolderInputDialog(context);
                          if (folderName != null && folderName.isNotEmpty) {
                            await _lessonService.addFolder(
                                widget.course.id, folderName);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FolderDetailScreen(
                                  courseId: widget.course.id,
                                  folder:
                                      LessonFolder(id: '', name: folderName),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<List<LessonFolder>>(
                    stream: _lessonService.getFolders(widget.course.id).map(
                          (folders) => folders
                              .where((f) => f.parentFolderName == null)
                              .toList(),
                        ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      final folders = snapshot.data!;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: folders.map((folder) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FolderDetailScreen(
                                    courseId: widget.course.id,
                                    folder: folder,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.42,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 40,
                                    color: Colors.amber[700],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    folder.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  // Lessons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Program Latihan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: MyColor.primaryColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddLessonScreen(courseId: widget.course.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<List<Lesson>>(
                    stream: _lessonService.getLessons(widget.course.id, userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Center(child: Text('Error loading lessons'));
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());

                      lessons = snapshot.data!
                          .where((lesson) => lesson.folderName == '')
                          .toList();
                      lessons.sort((a, b) => a.index.compareTo(b.index));

                      return ReorderableListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        onReorder: (oldIndex, newIndex) async {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final movedLesson = lessons.removeAt(oldIndex);
                            lessons.insert(newIndex, movedLesson);
                          });

                          final batch = FirebaseFirestore.instance.batch();
                          for (int i = 0; i < lessons.length; i++) {
                            if (lessons[i].index != i) {
                              lessons[i].index = i;
                              final docRef = FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(widget.course.id)
                                  .collection('lessons')
                                  .doc(lessons[i].id);
                              batch.update(docRef, {'index': i});
                            }
                          }
                          await batch.commit();
                        },
                        children: lessons.map((lesson) {
                          return Container(
                            key: ValueKey(lesson.id),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                child: lesson.image.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          lesson.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.fitness_center,
                                          size: 30,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                              title: Text(
                                lesson.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    lesson.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_vert),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColor.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMemberScreen(courseId: widget.course.id),
            ),
          );
        },
        child: Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }
}
