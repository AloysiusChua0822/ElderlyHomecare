import 'package:flutter/material.dart';
import 'package:eldergit/classes/newsclass.dart'; // Make sure this class has a field for the image URL

class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (newsItem.imageUrl.isNotEmpty)
              Image.network(
                newsItem.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                newsItem.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                newsItem.content,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                newsItem.description, // Assuming 'description' is the field for detailed description
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
