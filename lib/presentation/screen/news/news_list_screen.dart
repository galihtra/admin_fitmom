import 'package:admin_fitmom/core/utils/my_strings.dart';
import 'package:flutter/material.dart';
import '../../../data/model/news/news_model.dart';
import '../../../data/services/news/news_service.dart';
import 'details_news/news_detail_screen.dart';
import 'widget/floating_action_button_custom.dart';

class NewsListScreen extends StatelessWidget {
  final NewsService _newsService = NewsService();

  NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(MyStrings.beritaDanTips)),
      body: StreamBuilder<List<NewsModel>>(
        stream: _newsService.getNewsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada berita"));
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return ListTile(
                leading: Image.network(news.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(news.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(news.category),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(news: news)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: const FloatingActionButtonCustom(),
    );
  }
}
