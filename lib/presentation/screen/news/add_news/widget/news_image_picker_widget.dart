import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewsImagePicker extends StatefulWidget {
  final File? image;
  final String? imageUrl;
  final Function(File?) onImagePicked;

  const NewsImagePicker({
    super.key,
    required this.image,
    required this.imageUrl,
    required this.onImagePicked,
  });

  @override
  _NewsImagePickerState createState() => _NewsImagePickerState();
}

class _NewsImagePickerState extends State<NewsImagePicker> {
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
          image: widget.image != null
              ? DecorationImage(image: FileImage(widget.image!), fit: BoxFit.cover)
              : widget.imageUrl != null
                  ? DecorationImage(image: NetworkImage(widget.imageUrl!), fit: BoxFit.cover)
                  : null,
        ),
        child: widget.image == null && widget.imageUrl == null
            ? const Center(
                child: Text("Pilih Gambar", style: TextStyle(color: Colors.grey)),
              )
            : null,
      ),
    );
  }
}
