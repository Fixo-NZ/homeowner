class TradieRecommendation {
  final int id;
  final String name;
  final String occupation;
  final double? rating;
  final String serviceArea;
  final int? yearsExperience;
  final double? distanceKm;
  final double? hourlyRate;
  final String availability;
  final List<String> skills;
  final String? profileImage;
  final bool isVerified;
  final bool isTopRated;
  final int? jobsCompleted;
  final int? reviewsCount;

  /// Backwards-compatible getter used by UI (`reviewCount`) — maps to `reviewsCount`.
  int? get reviewCount => reviewsCount;

  TradieRecommendation({
    required this.id,
    required this.name,
    required this.occupation,
    this.rating,
    required this.serviceArea,
    this.yearsExperience,
    this.distanceKm,
    this.hourlyRate,
    required this.availability,
    this.skills = const [],
    this.profileImage,
    this.isVerified = false,
    this.isTopRated = false,
    this.jobsCompleted,
    this.reviewsCount,
  });

  factory TradieRecommendation.fromJson(Map<String, dynamic> json) {
    return TradieRecommendation(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse('${json['id']}') ?? 0),
      name: json['name'] ?? '',
      occupation: json['occupation'] ?? '',
      rating: json['rating'] is double
          ? json['rating'] as double
          : double.tryParse('${json['rating']}'),
      serviceArea: json['service_area'] ?? '',
      yearsExperience: json['years_experience'] is int
          ? json['years_experience'] as int
          : int.tryParse('${json['years_experience']}'),
      distanceKm: json['distance_km'] is double
          ? json['distance_km'] as double
          : double.tryParse('${json['distance_km']}'),
      hourlyRate: json['hourly_rate'] is double
          ? json['hourly_rate'] as double
          : double.tryParse('${json['hourly_rate']}'),
      availability: json['availability'] ?? 'unknown',
      skills: json['skills'] is List ? List<String>.from(json['skills']) : [],
      profileImage: json['profile_image'],
      isVerified: json['is_verified'] == true,
      isTopRated: json['is_top_rated'] == true,
      jobsCompleted: json['jobs_completed'] is int
          ? json['jobs_completed'] as int
          : int.tryParse('${json['jobs_completed']}'),

      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count'] as int
          : int.tryParse('${json['reviews_count']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'occupation': occupation,
      'rating': rating,
      'service_area': serviceArea,
      'years_experience': yearsExperience,
      'distance_km': distanceKm,
      'hourly_rate': hourlyRate,
      'availability': availability,
      'skills': skills,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'is_top_rated': isTopRated,
      'jobs_completed': jobsCompleted,
      'reviews_count': reviewsCount,
    };
  }

  TradieRecommendation copyWith({
    int? id,
    String? name,
    String? occupation,
    double? rating,
    String? serviceArea,
    int? yearsExperience,
    double? distanceKm,
    double? hourlyRate,
    String? availability,
    List<String>? skills,
    String? profileImage,
    bool? isVerified,
    bool? isTopRated,
    int? jobsCompleted,
    int? reviewsCount,
  }) {
    return TradieRecommendation(
      id: id ?? this.id,
      name: name ?? this.name,
      occupation: occupation ?? this.occupation,
      rating: rating ?? this.rating,
      serviceArea: serviceArea ?? this.serviceArea,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      distanceKm: distanceKm ?? this.distanceKm,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      availability: availability ?? this.availability,
      skills: skills ?? this.skills,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      isTopRated: isTopRated ?? this.isTopRated,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  String get formattedRating {
    if (rating == null) return 'No rating';
    return rating!.toStringAsFixed(1);
  }

  String get formattedDistance {
    if (distanceKm == null) return 'Distance unknown';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String get formattedHourlyRate {
    if (hourlyRate == null) return 'Rate not specified';
    return '\$${hourlyRate!.toStringAsFixed(0)}/hr';
  }

  String get availabilityText {
    switch (availability.toLowerCase()) {
      case 'available':
        return 'Available today';
      case 'busy':
        return 'Available tomorrow';
      case 'unavailable':
        return 'Not available';
      default:
        return 'Availability unknown';
    }
  }
}

class TradieRecommendationResponse {
  final bool success;
  final String message;
  final int? serviceId;
  final List<TradieRecommendation> recommendations;

  TradieRecommendationResponse({
    required this.success,
    required this.message,
    this.serviceId,
    this.recommendations = const [],
  });

  factory TradieRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return TradieRecommendationResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      serviceId: json['serviceId'] is int
          ? json['serviceId'] as int
          : int.tryParse('${json['serviceId']}'),
      recommendations: json['recommendations'] is List
          ? (json['recommendations'] as List)
                .map((e) => TradieRecommendation.fromJson(e))
                .toList()
          : [],
    );
  }
}
