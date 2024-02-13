class Activity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  Activity({required this.id, required this.title, required this.description, required this.imageUrl});

  factory Activity.fromFirestore(Map<String, dynamic> firestoreDoc, String id) {
    return Activity(
      id: id,
      title: firestoreDoc['title'] ?? '',
      description: firestoreDoc['description'] ?? '',
      imageUrl: firestoreDoc['imageUrl'] ?? '',
    );
  }
}