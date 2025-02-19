import 'package:admin_fitmom/core/utils/my_color.dart';
import 'package:flutter/material.dart';
import '../../../data/model/category/category_news_model.dart';
import '../../../data/services/category_news/category_news_service.dart';
import 'widget/add_category_modal.dart';
import 'widget/category_card.dart';

class CategoryNewsScreen extends StatelessWidget {
  final CategoryNewsService _categoryService = CategoryNewsService();

  CategoryNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori Berita")),
      body: StreamBuilder<List<CategoryNewsModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada kategori berita",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  category: category,
                  onDelete: () async {
                    await _categoryService.deleteCategory(category.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddCategoryDialog(context),
        backgroundColor: MyColor.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
