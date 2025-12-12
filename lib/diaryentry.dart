class DiaryEntry {
  int? id;
  String title;
  String notes;
  String date;
  String? imagePath;

  DiaryEntry({
    this.id,
    required this.title,
    required this.notes,
    required this.date,
    this.imagePath,
  });

  // Convert object → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'date': date,
      'imagePath': imagePath,
    };
  }

  // Convert Map → Object
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      notes: map['notes'],
      date: map['date'],
      imagePath: map['imagePath'],
    );
  }
}
