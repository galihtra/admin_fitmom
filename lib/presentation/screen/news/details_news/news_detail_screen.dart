import 'package:flutter/material.dart';

import '../../../../data/model/news/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(news.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(news.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Kategori: ${news.category}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text("Penulis: ${news.author}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(news.content),
          ],
        ),
      ),
    );
  }
}
