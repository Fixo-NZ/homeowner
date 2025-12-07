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
    // Handle Laravel API response structure
    String name = json['name'] ?? '';
    if (name.isEmpty && (json['first_name'] != null || json['last_name'] != null)) {
      final firstName = json['first_name']?.toString() ?? '';
      final lastName = json['last_name']?.toString() ?? '';
      name = '$firstName $lastName'.trim();
    }
    
    double rating = 0.0;
    if (json['average_rating'] != null) {
      rating = double.tryParse(json['average_rating'].toString()) ?? 0.0;
    } else if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString()) ?? 0.0;
    }
    
    String hourlyRateStr = '\$85/hr';
    if (json['hourly_rate'] != null) {
      final rate = double.tryParse(json['hourly_rate'].toString());
      if (rate != null) {
        hourlyRateStr = '\$${rate.toStringAsFixed(0)}/hr';
      }
    }
    
    String location = json['location'] ?? '';
    if (location.isEmpty) {
      final city = json['city']?.toString() ?? '';
      final region = json['region']?.toString() ?? '';
      location = [city, region].where((s) => s.isNotEmpty).join(', ');
    }
    
    double distance = 0.0;
    if (json['distance_km'] != null) {
      distance = double.tryParse(json['distance_km'].toString()) ?? 0.0;
    } else if (json['distance'] != null) {
      distance = double.tryParse(json['distance'].toString()) ?? 0.0;
    }
    
    return Tradie(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse('${json['id']}') ?? 0),
      name: name,
      profession: json['profession'] ?? 
                  json['business_name']?.toString() ?? 
                  'Tradie',
      profileImage: json['profile_image'] ?? 
                    json['avatar']?.toString(),
      rating: rating,
      hourlyRate: hourlyRateStr,
      location: location.isNotEmpty ? location : 'Location not specified',
      distance: distance,
      availableToday: json['available_today'] ?? 
                      (json['availability_status']?.toString() == 'available'),
    );
  }
}
