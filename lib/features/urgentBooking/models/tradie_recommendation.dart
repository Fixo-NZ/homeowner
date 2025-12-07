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

  /// fixed version of TradieRecommendation.fromJson
  /// Handles Laravel API response structure from /jobs/{id}/recommend-tradies
  factory TradieRecommendation.fromJson(Map<String, dynamic> json) {
    // Handle Laravel API response structure
    // Laravel returns: { id, name, business_name, distance_km, average_rating, 
    //                    total_reviews, hourly_rate, availability, services, ... }
    
    // Parse name - can be full name or first_name + last_name
    String name = json['name'] ?? '';
    if (name.isEmpty) {
      final firstName = json['first_name']?.toString() ?? '';
      final lastName = json['last_name']?.toString() ?? '';
      name = '$firstName $lastName'.trim();
    }
    
    // Parse occupation/business name
    String occupation = json['occupation'] ?? 
                        json['business_name']?.toString() ?? 
                        'Tradie';
    
    // Parse rating - Laravel uses average_rating
    double? rating;
    if (json['average_rating'] != null) {
      rating = double.tryParse(json['average_rating'].toString());
    } else if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString());
    }
    
    // Parse service area - Laravel uses city/region
    String serviceArea = json['service_area'] ?? '';
    if (serviceArea.isEmpty) {
      final city = json['city']?.toString() ?? '';
      final region = json['region']?.toString() ?? '';
      serviceArea = [city, region].where((s) => s.isNotEmpty).join(', ');
    }
    
    // Parse services list - Laravel returns as List<String>
    final rawSkills = json['services'] ?? json['skills'];
    final List<String> safeSkills = (rawSkills is List)
        ? rawSkills
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList()
        : [];
    
    // Parse distance - Laravel uses distance_km
    double? distanceKm;
    if (json['distance_km'] != null) {
      distanceKm = double.tryParse(json['distance_km'].toString());
    } else if (json['distance'] != null) {
      distanceKm = double.tryParse(json['distance'].toString());
    }
    
    // Parse hourly rate
    double? hourlyRate;
    if (json['hourly_rate'] != null) {
      hourlyRate = double.tryParse(json['hourly_rate'].toString());
    }
    
    // Parse availability - Laravel uses availability_status or availability
    String availability = json['availability']?.toString() ?? 
                         json['availability_status']?.toString() ?? 
                         'unknown';
    
    // Parse reviews count - Laravel uses total_reviews
    int? reviewsCount;
    if (json['total_reviews'] != null) {
      reviewsCount = int.tryParse(json['total_reviews'].toString());
    } else if (json['reviews_count'] != null) {
      reviewsCount = int.tryParse(json['reviews_count'].toString());
    }
    
    // Parse profile image - Laravel uses avatar
    String? profileImage = json['profile_image']?.toString() ?? 
                           json['avatar']?.toString();

    return TradieRecommendation(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse('${json['id']}') ?? 0),
      name: name,
      occupation: occupation,
      rating: rating,
      serviceArea: serviceArea,
      yearsExperience: json['years_experience'] is int
          ? json['years_experience'] as int
          : int.tryParse('${json['years_experience']}'),
      distanceKm: distanceKm,
      hourlyRate: hourlyRate,
      availability: availability,
      skills: safeSkills,
      profileImage: profileImage,
      isVerified: json['is_verified'] == true || json['verified_at'] != null,
      isTopRated: json['is_top_rated'] == true || (rating != null && rating! >= 4.5),
      jobsCompleted: json['jobs_completed'] is int
          ? json['jobs_completed'] as int
          : int.tryParse('${json['jobs_completed']}'),
      reviewsCount: reviewsCount,
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
    // Handle Laravel API response: { success: true, count: X, data: [...] }
    List<TradieRecommendation> recommendations = [];
    
    if (json['success'] == true && json['data'] is List) {
      recommendations = (json['data'] as List)
          .map((e) => TradieRecommendation.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (json['recommendations'] is List) {
      recommendations = (json['recommendations'] as List)
          .map((e) => TradieRecommendation.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    
    return TradieRecommendationResponse(
      success: json['success'] == true,
      message: json['message'] ?? 'Recommendations fetched successfully',
      serviceId: json['serviceId'] is int
          ? json['serviceId'] as int
          : int.tryParse('${json['serviceId']}'),
      recommendations: recommendations,
    );
  }
}
