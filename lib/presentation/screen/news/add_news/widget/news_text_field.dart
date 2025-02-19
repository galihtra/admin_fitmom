import 'package:flutter/material.dart';

class NewsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const NewsTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
      ),
    );
  }
}
