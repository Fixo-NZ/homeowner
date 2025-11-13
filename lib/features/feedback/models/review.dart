class Review {
  String name;
  int rating;
  final DateTime date;
  String comment;
  int likes;
  bool isLiked;
  bool isEdited;
  List<String> mediaFiles;
  final String? contractorId;

  Review({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
    required this.likes,
    this.isLiked = false,
    this.isEdited = false,
    this.mediaFiles = const [],
    this.contractorId,
  });

  // Factory constructor for JSON deserialization
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] ?? '',
      rating: json['rating'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      comment: json['comment'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      mediaFiles: const [],
      contractorId: json['contractorId'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'date': date.toIso8601String(),
      'comment': comment,
      'likes': likes,
      'isLiked': isLiked,
      'isEdited': isEdited,
      'contractorId': contractorId,
    };
  }
}