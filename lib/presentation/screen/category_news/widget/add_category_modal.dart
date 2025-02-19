import 'package:flutter/material.dart';
import '../../../../data/model/category/category_news_model.dart';
import '../../../../data/services/category_news/category_news_service.dart';

void showAddCategoryDialog(BuildContext context) {
  final TextEditingController _categoryController = TextEditingController();
  final CategoryNewsService _categoryService = CategoryNewsService();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Kategori",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: "Nama Kategori",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_categoryController.text.isNotEmpty) {
                        final category = CategoryNewsModel(
                          id: '',
                          category: _categoryController.text,
                        );
                        await _categoryService.addCategory(category);
                        _categoryController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
