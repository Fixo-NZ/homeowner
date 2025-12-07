class TradieModel {
  final int id;
  final String name;
  final String? occupation;
  final double? rating;
  final String? serviceArea;
  final int? yearsExperience;
  final double? hourlyRate;
  final List<TradieSkill> skills;
  final double? distance; // Distance in km from job location
  final String? availability; // availability_status from API
  final int? serviceRadius; // service_radius_km from API
  final String? city;
  final String? region;
  final String? avatar;

  TradieModel({
    required this.id,
    required this.name,
    this.occupation,
    this.rating,
    this.serviceArea,
    this.yearsExperience,
    this.hourlyRate,
    this.skills = const [],
    this.distance,
    this.availability,
    this.serviceRadius,
    this.city,
    this.region,
    this.avatar,
  });

  factory TradieModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : (int.tryParse('${json['id']}') ?? 0);
    final first = json['first_name'] ?? json['name'] ?? '';
    final last = json['last_name'] ?? '';
    final name = ((json['name'] ?? '').toString().isNotEmpty)
        ? json['name'].toString()
        : ('$first ${last ?? ''}').trim();

    double? rating;
    if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString());
    } else if (json['average_rating'] != null) {
      rating = double.tryParse(json['average_rating'].toString());
    }

    double? hourly;
    if (json['hourly_rate'] != null) {
      hourly = double.tryParse(json['hourly_rate'].toString());
    }

    final skillsJson = json['skills'];
    List<TradieSkill> skills = [];
    if (skillsJson is List) {
      skills = skillsJson.map((e) {
        if (e is Map<String, dynamic>) {
          return TradieSkill.fromJson(e);
        } else {
          return TradieSkill(id: 0, name: e.toString());
        }
      }).toList();
    }

    // Handle Laravel API response structure
    double? distance;
    if (json['distance_km'] != null) {
      distance = double.tryParse(json['distance_km'].toString());
    } else if (json['distance'] != null) {
      distance = double.tryParse(json['distance'].toString());
    }

    // Handle services list from Laravel API
    List<String> servicesList = [];
    if (json['services'] != null) {
      if (json['services'] is List) {
        servicesList = json['services'].map((e) => e.toString()).toList();
      }
    }

    return TradieModel(
      id: id,
      name: name,
      occupation: json['occupation'] ?? json['business_name'] ?? '',
      rating: rating ?? 0.0,
      serviceArea: json['service_area'] ?? 
                   json['city'] ?? 
                   json['region'] ?? 
                   '',
      yearsExperience: json['years_experience'] is int
          ? json['years_experience'] as int
          : (json['years_experience'] != null
                ? int.tryParse('${json['years_experience']}')
                : null),
      hourlyRate: hourly,
      skills: servicesList.isNotEmpty
          ? servicesList.map((s) => TradieSkill(id: 0, name: s)).toList()
          : skills,
      distance: distance,
      availability: json['availability']?.toString(),
      serviceRadius: json['service_radius_km'] is int
          ? json['service_radius_km'] as int
          : (json['service_radius_km'] != null
                ? int.tryParse('${json['service_radius_km']}')
                : null),
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class TradieSkill {
  final int id;
  final String name;
  final String? level;

  TradieSkill({required this.id, required this.name, this.level});

  factory TradieSkill.fromJson(Map<String, dynamic> json) {
    return TradieSkill(
      id: json['skill_id'] is int
          ? json['skill_id'] as int
          : (json['id'] is int ? json['id'] as int : 0),
      name: (json['name'] ?? json['skill_name'] ?? '').toString(),
      level: json['level']?.toString(),
    );
  }
}
