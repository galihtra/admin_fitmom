import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../../data/model/news/news_model.dart';
import '../../../../data/services/news/news_service.dart';
import 'widget/news_category_dropdown.dart';
import 'widget/news_image_picker_widget.dart';
import 'widget/news_save_button.dart';
import 'widget/news_text_field.dart';

class AddNewsScreen extends StatefulWidget {
  final NewsModel? news;

  const AddNewsScreen({super.key, this.news});

  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newsService = NewsService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  File? _image;
  String? _imageUrl;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
      _authorController.text = widget.news!.author;
      _selectedCategory = widget.news!.category;
      _imageUrl = widget.news!.imageUrl;
    }
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

  Future<void> _saveNews() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null && _imageUrl == null) await _uploadImage();
      final news = NewsModel(
        id: widget.news?.id ?? '',
        title: _titleController.text,
        content: _contentController.text,
        author: _authorController.text,
        category: _selectedCategory ?? '',
        imageUrl: _imageUrl ?? '',
        publishDate: DateTime.now(),
      );
      widget.news == null
          ? await _newsService.addNews(news)
          : await _newsService.updateNews(widget.news!.id, news);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.news == null ? "Tambah Berita" : "Edit Berita")),
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
              NewsSaveButton(isLoading: _isLoading, onPressed: _saveNews),
            ],
          ),
        ),
      ),
    );
  }
}
