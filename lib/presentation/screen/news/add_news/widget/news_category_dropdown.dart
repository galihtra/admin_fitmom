import 'package:flutter/material.dart';

import '../../../../../data/model/category_news/category_news_model.dart';
import '../../../../../data/services/category_news/category_news_service.dart';

class NewsCategoryDropdown extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;

  const NewsCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  _NewsCategoryDropdownState createState() => _NewsCategoryDropdownState();
}

class _NewsCategoryDropdownState extends State<NewsCategoryDropdown> {
  final _categoryService = CategoryNewsService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StreamBuilder<List<CategoryNewsModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final categories = snapshot.data!;

          return DropdownButtonFormField<String>(
            value: widget.selectedCategory,
            hint: const Text("Pilih Kategori"),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category.category,
                child: Text(category.category),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: (value) => value == null ? "Pilih kategori" : null,
            decoration: const InputDecoration(
              labelText: "Kategori",
              border: OutlineInputBorder(),
            ),
          );
        },
      ),
    );
  }
}
