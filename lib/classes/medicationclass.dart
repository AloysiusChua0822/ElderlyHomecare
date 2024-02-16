class Medication {
  String id;
  String name;
  String dosage;
  String frequency;
  String? imageUrl;

  Medication({required this.id, required this.name, required this.dosage, required this.frequency, this.imageUrl});

  factory Medication.fromFirestore(Map<String, dynamic> firestoreDoc, String documentId) {
    return Medication(
      id: documentId,
      name: firestoreDoc['name'],
      dosage: firestoreDoc['dosage'],
      frequency: firestoreDoc['frequency'],
      imageUrl: firestoreDoc['imageUrl'], // Handle imageUrl
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'imageUrl': imageUrl,
    };
  }
}
