import 'dart:convert';

class Review {
  String? id;
  String name;
  int rating;
  final DateTime date;
  String comment;
  int likes;
  bool isLiked;
  bool isEdited;
  List<String> mediaFiles;
  bool isSynced;
  final String? contractorId;

  Review({
    this.id,
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
    required this.likes,
    this.isLiked = false,
    this.isEdited = false,
    this.mediaFiles = const [],
    this.isSynced = true,
    this.contractorId,
  });

  // Factory constructor for JSON deserialization
  factory Review.fromJson(Map<String, dynamic> json) {
    final mediaRaw = json['mediaPaths'] ?? json['mediaFiles'] ?? [];
    final mediaList = <String>[];
    try {
      if (mediaRaw is String) {
        // stored as JSON string
        final parsed = (mediaRaw.isNotEmpty) ? List<String>.from(jsonDecode(mediaRaw) as List) : <String>[];
        mediaList.addAll(parsed);
      } else if (mediaRaw is List) {
        mediaList.addAll(mediaRaw.map((e) => e.toString()));
      }
    } catch (_) {
      // fallback: empty list
    }

    return Review(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      rating: json['rating'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      comment: json['comment'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      mediaFiles: mediaList,
      isSynced: json['isSynced'] ?? true,
      contractorId: json['contractorId'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'rating': rating,
      'date': date.toIso8601String(),
      'comment': comment,
      'likes': likes,
      'isLiked': isLiked,
      'isEdited': isEdited,
      'mediaPaths': mediaFiles,
      'isSynced': isSynced,
      'contractorId': contractorId,
    };
  }
}