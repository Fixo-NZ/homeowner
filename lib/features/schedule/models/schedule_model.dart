import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OfferResponse {
  final List<OfferModel> offers;

  OfferResponse({
    required this.offers,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) =>
      _$OfferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OfferResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OfferModel {
  final int id;
  @JsonKey(name: 'homeowner_id')
  final int homeownerId;
  @JsonKey(name: 'service_category_id')
  final int serviceCategoryId;
  @JsonKey(name: 'tradie_id')
  final int? tradieId;
  @JsonKey(name: 'job_type')
  final String jobType;
  @JsonKey(name: 'preferred_date')
  final String? preferredDate;
  final String? frequency;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String title;
  @JsonKey(name: 'job_size')
  final String jobSize;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'rescheduled_at')
  final String? rescheduledAt;
  @JsonKey(name: 'photo_urls')
  final List<String>? photoUrls;
  final Tradie? tradie;
  final Category category;
  final List<Photo>? photos;

  OfferModel({
    required this.id,
    required this.homeownerId,
    required this.serviceCategoryId,
    this.tradieId,
    required this.jobType,
    this.preferredDate,
    this.frequency,
    this.startDate,
    this.endDate,
    required this.title,
    required this.jobSize,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.startTime,
    required this.endTime,
    this.rescheduledAt,
    this.photoUrls,
    this.tradie,
    required this.category,
    this.photos,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) =>
      _$OfferModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferModelToJson(this);

  DateTime get startDateTime {
    try {
      // Handle format: "2025-12-12 14:57:00"
      return DateTime.parse(startTime.replaceFirst(' ', 'T'));
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }
  
  DateTime get endDateTime {
    try {
      // Handle format: "2025-12-13 18:00:00"
      return DateTime.parse(endTime.replaceFirst(' ', 'T'));
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }
  
  DateTime? get preferredDateTime {
    if (preferredDate == null) return null;
    try {
      return DateTime.parse(preferredDate!);
    } catch (e) {
      return null;
    }
  }
  
  DateTime? get startDateOnly {
    if (startDate == null) return null;
    try {
      return DateTime.parse(startDate!);
    } catch (e) {
      return null;
    }
  }
  
  DateTime? get endDateOnly {
    if (endDate == null) return null;
    try {
      return DateTime.parse(endDate!);
    } catch (e) {
      return null;
    }
  }

  // Helper methods for handling null tradie
  String get tradieDisplayName {
    return tradie?.fullName ?? 'No assigned tradie yet';
  }
  
  String get tradieEmail {
    return tradie?.email ?? 'Not available';
  }
  
  String get tradiePhone {
    return tradie?.phone ?? 'Not available';
  }
  
  String get tradieAddress {
    return tradie?.address ?? 'Not available';
  }
  
  String get tradieInitials {
    if (tradie == null) return 'NA';
    return '${tradie!.firstName[0]}${tradie!.lastName[0]}';
  }
}

@JsonSerializable()
class Tradie {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  final String email;
  final String address;
  final String phone;

  Tradie({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory Tradie.fromJson(Map<String, dynamic> json) =>
      _$TradieFromJson(json);

  Map<String, dynamic> toJson() => _$TradieToJson(this);

  String get fullName {
    final middle = middleName != null ? ' $middleName ' : ' ';
    return '$firstName$middle$lastName';
  }
}

// Extension to handle null tradie cases
extension OfferModelExtension on OfferModel {
  String get tradieDisplayName {
    return tradie?.fullName ?? 'No assigned tradie yet';
  }
  
  String get tradieEmail {
    return tradie?.email ?? 'Not available';
  }
  
  String get tradiePhone {
    return tradie?.phone ?? 'Not available';
  }
  
  String get tradieAddress {
    return tradie?.address ?? 'Not available';
  }
  
  String get tradieInitials {
    if (tradie == null) return 'NA';
    return '${tradie!.firstName[0]}${tradie!.lastName[0]}';
  }
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String status;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Photo {
  final int id;
  @JsonKey(name: 'job_offer_id')
  final int jobOfferId;
  @JsonKey(name: 'file_path')
  final String filePath;
  @JsonKey(name: 'original_name')
  final String originalName;
  @JsonKey(name: 'file_size')
  final int fileSize;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final String url;

  Photo({
    required this.id,
    required this.jobOfferId,
    required this.filePath,
    required this.originalName,
    required this.fileSize,
    this.createdAt,
    this.updatedAt,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) =>
      _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}