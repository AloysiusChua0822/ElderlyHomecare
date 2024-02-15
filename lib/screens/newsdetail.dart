import 'package:flutter/material.dart';
import 'package:eldergit/classes/newsclass.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $urlString';
    }
  }

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
            if (newsItem.linkurl.isNotEmpty) // Check if the link URL is not empty
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => _launchURL(newsItem.linkurl), // Launch the URL
                  child: Text(
                    newsItem.linkurl,
                    style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                newsItem.description,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
