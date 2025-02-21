import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../../data/model/news/news_model.dart';
import '../../../../data/services/news/news_service.dart';
import '../add_news/widget/news_category_dropdown.dart';
import '../add_news/widget/news_image_picker_widget.dart';
import '../add_news/widget/news_save_button.dart';
import '../add_news/widget/news_text_field.dart';

class UpdateNewsScreen extends StatefulWidget {
  final NewsModel news;

  const UpdateNewsScreen({super.key, required this.news});

  @override
  _UpdateNewsScreenState createState() => _UpdateNewsScreenState();
}

class _UpdateNewsScreenState extends State<UpdateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newsService = NewsService();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;
  File? _image;
  String? _imageUrl;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news.title);
    _contentController = TextEditingController(text: widget.news.content);
    _authorController = TextEditingController(text: widget.news.author);
    _selectedCategory = widget.news.category;
    _imageUrl = widget.news.imageUrl;
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('news_images/${DateTime.now().toIso8601String()}');
      await ref.putFile(_image!);
      _imageUrl = await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengupload gambar: $e")));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateNews() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null && _imageUrl == widget.news.imageUrl)
        await _uploadImage();
      final updatedNews = NewsModel(
        id: widget.news.id,
        title: _titleController.text,
        content: _contentController.text,
        author: _authorController.text,
        category: _selectedCategory ?? '',
        imageUrl: _imageUrl ?? '',
        publishDate: widget.news.publishDate,
      );
      await _newsService.updateNews(widget.news.id, updatedNews);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const HomeScreen(initialTabIndex: 1)),
      // );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Berita")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              NewsTextField(controller: _titleController, label: "Judul"),
              NewsTextField(
                  controller: _contentController, label: "Konten", maxLines: 5),
              NewsTextField(controller: _authorController, label: "Penulis"),
              NewsCategoryDropdown(
                selectedCategory: _selectedCategory,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              NewsImagePicker(
                image: _image,
                imageUrl: _imageUrl,
                onImagePicked: (file) => setState(() => _image = file),
              ),
              const SizedBox(height: 20),
              NewsSaveButton(isLoading: _isLoading, onPressed: _updateNews),
            ],
          ),
        ),
      ),
    );
  }
}
