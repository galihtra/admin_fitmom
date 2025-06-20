import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../data/services/testimonial/testimonial_service.dart';

class AddTestimonialScreen extends StatefulWidget {
  const AddTestimonialScreen({super.key});

  @override
  State<AddTestimonialScreen> createState() => _AddTestimonialScreenState();
}

class _AddTestimonialScreenState extends State<AddTestimonialScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final TestimonialService _testimonialService = TestimonialService();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.pinkAccent),
              SizedBox(height: 20),
              Text(
                "Menyimpan testimonial...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTestimonial() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    _showLoadingDialog();

    try {
      await _testimonialService.addTestimonial({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': _image!.path,
      });

      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Back to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testimonial berhasil ditambahkan')),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan testimonial: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Testimonial"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  _image == null
                      ? const Icon(Icons.image, size: 100, color: Colors.grey)
                      : Image.file(_image!, width: 150, height: 150),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pilih Gambar"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTestimonial,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                child: const Text("Tambahkan Testimonial",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
