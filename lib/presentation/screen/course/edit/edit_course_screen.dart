import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/model/course/course.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  const EditCourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.name);
    _descriptionController = TextEditingController(text: widget.course.description);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    String fileName = 'course_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.course.image; // Gambar lama
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToStorage(_selectedImage!); // Upload dan dapatkan URL baru
      }

      await FirebaseFirestore.instance.collection('courses').doc(widget.course.id).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course updated successfully')));
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update course: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : widget.course.image.isNotEmpty
                                      ? NetworkImage(widget.course.image)
                                      : AssetImage('assets/placeholder.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _selectedImage == null && widget.course.image.isEmpty
                              ? Center(
                                  child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Course Title'),
                        validator: (value) => value!.isEmpty ? 'Please enter a course title' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Course Description'),
                        validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateCourse,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
