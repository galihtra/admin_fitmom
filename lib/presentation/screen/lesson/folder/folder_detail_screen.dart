import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late LessonFolder _currentFolder = widget.folder; // Initialize directly

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.folder;
  }

  void _deleteLesson(BuildContext context, Lesson lesson) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Lesson'),
            content: Text('Are you sure you want to delete ${lesson.name}?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text('Cancel', style: TextStyle(color: Colors.grey[600])),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson ${lesson.name} deleted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteFolder(BuildContext context) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Folder'),
            content: Text(
                'Are you sure you want to delete this folder and all its contents?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text('Cancel', style: TextStyle(color: Colors.grey[600])),
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
      try {
        // Delete all lessons in this folder first
        final lessons = await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('lessons')
            .where('folderName', isEqualTo: _currentFolder.name)
            .get();

        final batch = _firestore.batch();
        for (var doc in lessons.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        // Then delete the folder itself
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('folders')
            .doc(_currentFolder.id)
            .delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete folder: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editFolder(BuildContext context) async {
    String newFolderName = _currentFolder.name;
    final oldFolderName =
        _currentFolder.name; // Store the original name before editing

    final updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Folder Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Folder name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  controller: TextEditingController(text: _currentFolder.name),
                  onChanged: (value) => newFolderName = value.trim(),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (newFolderName.isNotEmpty) {
                          Navigator.pop(context, newFolderName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (updatedName != null &&
        updatedName.isNotEmpty &&
        updatedName != _currentFolder.name) {
      try {
        // First update the folder document itself
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('folders')
            .doc(_currentFolder.id)
            .update({'name': updatedName});

        // Then update all lessons that reference this folder by its old name
        final lessonsQuery = await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('lessons')
            .where('folderName', isEqualTo: oldFolderName)
            .get();

        // Use batch update for atomic operation
        final batch = _firestore.batch();
        for (final doc in lessonsQuery.docs) {
          batch.update(doc.reference, {'folderName': updatedName});
        }
        await batch.commit();

        // Also update any subfolders that reference this folder as parent
        final subfoldersQuery = await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('folders')
            .where('parent_folder_name', isEqualTo: oldFolderName)
            .get();

        final subfolderBatch = _firestore.batch();
        for (final doc in subfoldersQuery.docs) {
          subfolderBatch
              .update(doc.reference, {'parent_folder_name': updatedName});
        }
        await subfolderBatch.commit();

        if (!mounted) return;
        setState(() {
          _currentFolder = LessonFolder(
            id: _currentFolder.id,
            name: updatedName,
            parentFolderName: _currentFolder.parentFolderName,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Folder and all associated content updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rename folder: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Revert the folder name in UI if update failed
        setState(() {
          _currentFolder = LessonFolder(
            id: _currentFolder.id,
            name: oldFolderName,
            parentFolderName: _currentFolder.parentFolderName,
          );
        });
      }
    }
  }

  Future<void> _addFolder() async {
    String newFolderName = '';

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create New Folder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Folder name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => newFolderName = value.trim(),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (newFolderName.isNotEmpty) {
                          Navigator.pop(context, newFolderName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (folderName != null && folderName.isNotEmpty) {
      try {
        final newFolderDoc = await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('folders')
            .add({
          'name': folderName,
          'parent_folder_name': _currentFolder.name,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Folder '$folderName' created successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderDetailScreen(
              courseId: widget.courseId,
              folder: LessonFolder(
                id: newFolderDoc.id,
                name: folderName,
                parentFolderName: _currentFolder.name,
              ),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create folder: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  int naturalCompare(String a, String b) {
    final regex = RegExp(r'(\d+|\D+)');
    final aParts = regex.allMatches(a).map((m) => m.group(0)!).toList();
    final bParts = regex.allMatches(b).map((m) => m.group(0)!).toList();

    for (var i = 0; i < aParts.length && i < bParts.length; i++) {
      final aPart = aParts[i];
      final bPart = bParts[i];

      final aNum = int.tryParse(aPart);
      final bNum = int.tryParse(bPart);

      if (aNum != null && bNum != null) {
        if (aNum != bNum) return aNum - bNum;
      } else {
        final comparison = aPart.compareTo(bPart);
        if (comparison != 0) return comparison;
      }
    }

    return aParts.length - bParts.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentFolder.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: MyColor.secondaryColor),
                    SizedBox(width: 8),
                    Text('Edit Folder'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Folder'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editFolder(context);
              } else if (value == 'delete') {
                _deleteFolder(context);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // === SUB FOLDERS ===
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('folders')
                    .where('parent_folder_name', isEqualTo: _currentFolder.name)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox();

                  final folders = snapshot.data!.docs.map((doc) {
                    return LessonFolder.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList()
                    ..sort((a, b) =>
                        naturalCompare(a.name, b.name)); // Urutkan disini

                  if (folders.isEmpty) return SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Text(
                          "SUB FOLDERS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...folders.map((folder) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.folder,
                                color: Colors.orange[400],
                              ),
                            ),
                            title: Text(
                              folder.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FolderDetailScreen(
                                    courseId: widget.courseId,
                                    folder: folder,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // === LESSONS ===
              StreamBuilder<List<Lesson>>(
                stream: _lessonService.getLessons(widget.courseId, userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MyColor.primaryColor,
                        ),
                      ),
                    );
                  }

                  final lessons = snapshot.data!
                      .where(
                          (lesson) => lesson.folderName == _currentFolder.name)
                      .toList()
                    ..sort((a, b) => a.index
                        .compareTo(b.index)); // ✅ berdasarkan waktu ditambahkan

                  if (lessons.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No Lessons Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemCount: lessons.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return Material(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: InkWell(
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
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        SizedBox(height: 6),
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
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.grey[400]),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                            Icon(Icons.delete,
                                                color: Colors.red),
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
                                                EditLessonScreen(
                                                    lesson: lesson),
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
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addFolder',
            backgroundColor: MyColor.primaryColor,
            child: Icon(Icons.create_new_folder, color: Colors.white),
            onPressed: _addFolder,
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addLesson',
            backgroundColor: MyColor.primaryColor,
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLessonScreen(
                    courseId: widget.courseId,
                    folderName: _currentFolder.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
