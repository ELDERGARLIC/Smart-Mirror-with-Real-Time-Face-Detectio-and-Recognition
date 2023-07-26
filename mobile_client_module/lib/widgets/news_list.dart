import 'package:flutter/material.dart';
import 'package:realtime_face_detection/models/news.dart';

// Widget to show the News component in the application.
class NewsList extends StatelessWidget {
  final List<News> newsItems;

  const NewsList({super.key, required this.newsItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(5.0),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final newsItem = newsItems[index];
        return NewsCard(
          title: newsItem.title,
          date: newsItem.date,
          source: newsItem.source,
        );
      },
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String date;
  final String source;

  const NewsCard({
    Key? key,
    required this.title,
    required this.date,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Text(
              date,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              source,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
