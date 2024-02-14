class NewsItem {
  String id;
  String title;
  String content;
  String imageUrl;

  NewsItem({this.id = '', required this.title, required this.content, this.imageUrl = ''});

  factory NewsItem.fromFirestore(Map<String, dynamic> firestoreDoc, String documentId) {
    return NewsItem(
      id: documentId,
      title: firestoreDoc['title'] ?? '',
      content: firestoreDoc['content'] ?? '',
      imageUrl: firestoreDoc['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}