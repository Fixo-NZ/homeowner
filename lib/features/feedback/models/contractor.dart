class Contractor {
  final String id;
  final String name;
  final String specialty;
  final String avatar;
  final double rating;
  final int completedJobs;

  Contractor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.rating,
    required this.completedJobs,
  });

  // Factory constructor for JSON deserialization
  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      avatar: json['avatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatar': avatar,
      'rating': rating,
      'completedJobs': completedJobs,
    };
  }
}