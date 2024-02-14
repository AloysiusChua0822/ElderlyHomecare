class NewsItem {
  String id;
  String title;
  String content;
  String description;
  String imageUrl;

  NewsItem({this.id = '', required this.title, required this.content, required this.description, this.imageUrl = ''});

  factory NewsItem.fromFirestore(Map<String, dynamic> firestoreDoc, String documentId) {
    return NewsItem(
      id: documentId,
      title: firestoreDoc['title'] ?? '',
      content: firestoreDoc['content'] ?? '',
      description: firestoreDoc['description'] ?? '',
      imageUrl: firestoreDoc['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}