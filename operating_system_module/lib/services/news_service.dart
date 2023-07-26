// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

// Service of fetching News from newsapi.org
Future<List<dynamic>> fetchNews() async {
  final response = await http.get(
    Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=tr&apiKey=a39d66d6fd11402b800513d65ec44a1d'),
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final articles = jsonData['articles'];
    return articles;
  } else {
    throw Exception('Failed to fetch news');
  }
}

// Usage example
void getNews() async {
  try {
    final news = await fetchNews();
    // Use the news data in UI
    print(news);
  } catch (e) {
    print('Error: $e');
  }
}
