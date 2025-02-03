class Note {
  final int id;
  final int userId;
  final String createdAt;
  final String title;
  final String description;
  final String status;

  Note({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.status,
  });

  // Método copyWith para actualizar campos sin modificar el objeto original
  Note copyWith({
    int? id,
    int? userId,
    String? createdAt,
    String? title,
    String? description,
    String? status,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
    );
  }
}
