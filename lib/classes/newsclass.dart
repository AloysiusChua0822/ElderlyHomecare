class NewsItem {
  String id;
  String title;
  String content;
  String description;
  String imageUrl;
  String linkurl;

  NewsItem({this.id = '', required this.title, required this.content, required this.description, required this.linkurl, this.imageUrl = ''});

  factory NewsItem.fromFirestore(Map<String, dynamic> firestoreDoc, String documentId) {
    return NewsItem(
      id: documentId,
      title: firestoreDoc['title'] ?? '',
      content: firestoreDoc['content'] ?? '',
      description: firestoreDoc['description'] ?? '',
      linkurl: firestoreDoc['linkurl'] ?? '',
      imageUrl: firestoreDoc['imageUrl'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'description': description,
      'linkurl' : linkurl,
      'imageUrl': imageUrl,
    };
  }
}