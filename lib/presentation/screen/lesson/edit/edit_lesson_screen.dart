import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/lesson/lesson_service.dart';

class EditLessonScreen extends StatefulWidget {
  final Lesson lesson;

  const EditLessonScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  _EditLessonScreenState createState() => _EditLessonScreenState();
}

class _EditLessonScreenState extends State<EditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final LessonService _lessonService = LessonService();

  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.lesson.name;
    _descriptionController.text = widget.lesson.description;
    _videoUrlController.text = widget.lesson.urlVideo;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('lesson_images/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  void _updateLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String imageUrl = widget
          .lesson.image; // Menggunakan URL lama jika tidak ada gambar baru
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      final updatedLesson = Lesson(
        id: widget.lesson.id,
        idCourse: widget.lesson.idCourse,
        name: _nameController.text,
        description: _descriptionController.text,
        image: imageUrl,
        urlVideo: _videoUrlController.text, // Update URL video dari controller
        isCompleted: widget.lesson.isCompleted,
        commentar: widget.lesson.commentar,
        ulasanPengguna: widget.lesson.ulasanPengguna,
        rating: widget.lesson.rating,
        index: widget.lesson.index,
      );

      await _lessonService.updateLesson(
        widget.lesson.idCourse, // courseId
        widget.lesson.id, // lessonId
        updatedLesson, // Lesson object yang diperbarui
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latihan updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Latihan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Latihan'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter lesson name' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickImage,
                  child: _image != null
                      ? Image.file(_image!,
                          width: 150, height: 150, fit: BoxFit.cover)
                      : widget.lesson.image.isNotEmpty
                          ? Image.network(widget.lesson.image,
                              width: 150, height: 150, fit: BoxFit.cover)
                          : Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: Icon(Icons.image,
                                  size: 50, color: Colors.grey[600]),
                            ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(labelText: 'Video URL'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter video URL' : null,
                ),
                const SizedBox(height: 20),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _updateLesson,
                        child: const Text('Update Latihan'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
