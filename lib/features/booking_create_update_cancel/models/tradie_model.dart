class Tradie {
  final int id;
  final String name;
  final String profession;
  final String? profileImage;
  final double rating;
  final String hourlyRate;
  final String location;
  final double distance;
  final bool availableToday;

  Tradie({
    required this.id,
    required this.name,
    required this.profession,
    this.profileImage,
    required this.rating,
    required this.hourlyRate,
    required this.location,
    required this.distance,
    this.availableToday = false,
  });

  factory Tradie.fromJson(Map<String, dynamic> json) {
    return Tradie(
      id: json['id'],
      name: json['name'],
      profession: json['profession'] ?? 'Tradie',
      profileImage: json['profile_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      hourlyRate: json['hourly_rate']?.toString() ?? '\$85/hr',
      location: json['location'] ?? 'Bondi, Sydney',
      distance: (json['distance'] ?? 0).toDouble(),
      availableToday: json['available_today'] ?? false,
    );
  }
}
