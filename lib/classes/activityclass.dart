class Activity {
  String id;
  String title;
  String description;
  String imageUrl;
  List<String> participants;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
  });

  factory Activity.fromFirestore(Map<String, dynamic> firestoreDoc, String documentId) {
    return Activity(
      id: documentId,
      title: firestoreDoc['title'],
      description: firestoreDoc['description'],
      imageUrl: firestoreDoc['imageUrl'] ?? '',
      participants: List<String>.from(firestoreDoc['participants'] ?? []),
    );
  }
}
