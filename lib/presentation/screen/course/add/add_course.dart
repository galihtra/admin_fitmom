import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/services/course/course_service.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CourseService _courseService = CourseService();
  File? _imageFile;
  bool _isUploading = false;
  bool _isFreeCourse = false; // Tambahkan variabel untuk status course gratis

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    String fileName = 'courses/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = await _uploadImage();

    final course = Course(
      id: '',
      name: _nameController.text,
      description: _descriptionController.text,
      image: imageUrl ?? '',
      isAvailable: true,
      isFinished: false,
      isFree: _isFreeCourse,
      members:
          _isFreeCourse ? [] : ['initialMember'], // Kosong untuk course gratis
    );

    await _courseService.addCourse(course);

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Kursus')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kursus',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Masukkan nama kursus' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Masukkan deskripsi' : null,
                ),
                SizedBox(height: 16),

                // Switch untuk menentukan course gratis
                Row(
                  children: [
                    Switch(
                      value: _isFreeCourse,
                      onChanged: (value) {
                        setState(() {
                          _isFreeCourse = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Kursus Gratis',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _isFreeCourse
                      ? 'Kursus ini akan tersedia untuk semua pengguna'
                      : 'Kursus ini hanya untuk member tertentu',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),

                // Upload gambar
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 50, color: Colors.grey[700]),
                              SizedBox(height: 8),
                              Text('Tambahkan Gambar',
                                  style: TextStyle(color: Colors.grey[700])),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_imageFile!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          ),
                  ),
                ),
                SizedBox(height: 20),

                // Tombol simpan
                _isUploading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // style: ElevatedButton.styleFrom(
                          //   primary: Colors.blueAccent,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          // ),
                          onPressed: _saveCourse,
                          child: Text(
                            'Simpan Kursus',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
