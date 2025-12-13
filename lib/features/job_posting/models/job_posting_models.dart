import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/photo_service.dart';

part 'job_posting_models.g.dart';

@JsonSerializable()
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get iconUrl {
    if (icon == null) return null;
    return '${ApiConstants.storageBaseUrl}/icons/$icon.svg';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}

@JsonSerializable()
class ServiceModel {
  final int id;
  final String name;
  final String? description;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}

enum JobType { standard, urgent, recurrent }

enum JobSize { small, medium, large }

enum Frequency { daily, weekly, monthly, quarterly, yearly, custom }

@JsonSerializable()
class JobPostRequest {
  @JsonKey(name: 'job_type')
  final JobType jobType;
  final Frequency? frequency;
  @JsonKey(name: 'preferred_date')
  final DateTime? preferredDate;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final String title;
  @JsonKey(name: 'job_size')
  final JobSize jobSize;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String>? photos;
  @JsonKey(name: 'services')
  final List<int> services;
  @JsonKey(name: 'service_category_id')
  final int categoryId;
  @JsonKey(name: 'homeowner_id')
  final int? homeownerId;

  const JobPostRequest({
    required this.jobType,
    this.frequency,
    this.preferredDate,
    this.startDate,
    this.endDate,
    required this.title,
    required this.jobSize,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.photos,
    required this.services,
    required this.categoryId,
    this.homeownerId,
  });

  factory JobPostRequest.fromJson(Map<String, dynamic> json) =>
      _$JobPostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JobPostRequestToJson(this);
}

@JsonSerializable()
class JobPostResponse {
  final int id;
  @JsonKey(name: 'homeowner_id')
  final int homeownerId;
  @JsonKey(name: 'service_category_id')
  final int serviceCategoryId; 
  @JsonKey(name: 'job_type')
  final String jobType;
  final String? frequency;
  @JsonKey(name: 'preferred_date')
  final DateTime? preferredDate;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final String title;
  @JsonKey(name: 'job_size')
  final String jobSize;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String>? photoUrls;
  
  final List<Map<String, dynamic>>? photos;
  

  final Map<String, dynamic>? category;
  final List<Map<String, dynamic>>? services;


  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const JobPostResponse({
    required this.id,
    required this.homeownerId,
    required this.serviceCategoryId,
    required this.jobType,
    this.frequency,
    this.preferredDate,
    this.startDate,
    this.endDate,
    required this.title,
    required this.jobSize,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.photoUrls,
    this.photos,
    this.category,
    this.services,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPostResponse.fromJson(Map<String, dynamic> json) =>
      _$JobPostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JobPostResponseToJson(this);

  // In JobPostResponse class
// Helper method to get category name
String? get categoryName => category?['name'] as String?;

// Helper method to get service IDs
List<int> get serviceIds {
  if (services == null) return [];
  return services!.map((service) => service['id'] as int).toList();
}

// Helper method to get service names
List<String> get serviceNames {
  if (services == null) return [];
  return services!.map((service) => service['name'] as String).toList();
}

// Helper method to get all photo URLs consistently
  List<String> get allPhotoUrls {
    if (photoUrls != null && photoUrls!.isNotEmpty) {
      return photoUrls!;
    }
    if (photos != null && photos!.isNotEmpty) {
      return photos!
          .map((photo) => photo['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

}

class JobPostFormData {
  final int? jobId;
  final CategoryModel? selectedCategory;
  final List<ServiceModel> selectedServices;
  final JobType jobType;
  final Frequency? frequency;
  final DateTime? preferredDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String title;
  final JobSize jobSize;
  final String? description;
  final String address;
  final List<File> photoFiles;
  final List<String> existingPhotoUrls;

  const JobPostFormData({
    this.jobId,
    this.selectedCategory,
    this.selectedServices = const [],
    this.jobType = JobType.standard,
    this.frequency,
    this.preferredDate,
    this.startDate,
    this.endDate,
    this.title = '',
    this.jobSize = JobSize.medium,
    this.description,
    this.address = '',
    this.photoFiles = const [],
    this.existingPhotoUrls = const [],
  });

  JobPostFormData copyWith({
    CategoryModel? selectedCategory,
    List<ServiceModel>? selectedServices,
    JobType? jobType,
    Frequency? frequency,
    DateTime? preferredDate,
    DateTime? startDate,
    DateTime? endDate,
    String? title,
    JobSize? jobSize,
    String? description,
    String? address,
    List<File>? photoFiles,
    List<String>? existingPhotoUrls,
  }) {
    return JobPostFormData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedServices: selectedServices ?? this.selectedServices,
      jobType: jobType ?? this.jobType,
      frequency: frequency ?? this.frequency,
      preferredDate: preferredDate ?? this.preferredDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      title: title ?? this.title,
      jobSize: jobSize ?? this.jobSize,
      description: description ?? this.description,
      address: address ?? this.address,
      photoFiles: photoFiles ?? this.photoFiles,
      existingPhotoUrls: existingPhotoUrls ?? this.existingPhotoUrls,
    );
  }

  // Helper method to convert to API request
  Future<JobPostRequest> toJobPostRequest() async {
    final base64Photos = await getPhotoBase64List();

    return JobPostRequest(
      jobType: jobType,
      frequency: frequency,
      preferredDate: preferredDate,
      startDate: startDate,
      endDate: endDate,
      title: title,
      jobSize: jobSize,
      description: description,
      address: address,
      latitude: null,
      longitude: null,
      photos: base64Photos.isNotEmpty ? base64Photos : null,
      services: selectedServices.map((service) => service.id).toList(),
      categoryId: selectedCategory!.id,
    );
  }

  Future<List<String>> getPhotoBase64List() async {
    if (photoFiles.isEmpty) {
      return [];
    }

    final List<String> base64Photos = [];

    for (final file in photoFiles) {
      try {
        final base64String = await PhotoService.fileToBase64(file);
        base64Photos.add(base64String);
      } catch (e) {
        print('Failed to convert photo to base64: $e');
      }
    }

    return base64Photos;
  }

  bool get arePhotosValid {
    if (photoFiles.isEmpty) return true;

    if (photoFiles.length > 5) return false;

    for (final file in photoFiles) {
      if (!file.existsSync()) return false;
    }

    return true;
  }

  // Validation methods
  bool get isCategorySelected => selectedCategory != null;
  bool get hasServicesSelected => selectedServices.isNotEmpty;
  bool get isTitleValid => title.trim().isNotEmpty;
  bool get isAddressValid => address.trim().isNotEmpty;

  bool get isFormValid {
    return isCategorySelected &&
        hasServicesSelected &&
        isTitleValid &&
        isAddressValid &&
        arePhotosValid;
  }

  // Add this factory constructor to your JobPostFormData class
  factory JobPostFormData.fromJobResponse({
    required JobPostResponse job,
    CategoryModel? selectedCategory,
    List<ServiceModel> selectedServices = const [],
  }) {
    // Convert job type
    final JobType jobType;
    switch (job.jobType.toLowerCase()) {
      case 'urgent':
        jobType = JobType.urgent;
        break;
      case 'recurrent':
        jobType = JobType.recurrent;
        break;
      default:
        jobType = JobType.standard;
    }

    // Convert job size
    final JobSize jobSize;
    switch (job.jobSize.toLowerCase()) {
      case 'small':
        jobSize = JobSize.small;
        break;
      case 'large':
        jobSize = JobSize.large;
        break;
      default:
        jobSize = JobSize.medium;
    }

    // Convert frequency
    Frequency? frequency;
    if (job.frequency != null && job.frequency!.isNotEmpty) {
      switch (job.frequency!.toLowerCase()) {
        case 'daily':
          frequency = Frequency.daily;
          break;
        case 'weekly':
          frequency = Frequency.weekly;
          break;
        case 'monthly':
          frequency = Frequency.monthly;
          break;
        case 'quarterly':
          frequency = Frequency.quarterly;
          break;
        case 'yearly':
          frequency = Frequency.yearly;
          break;
        case 'custom':
          frequency = Frequency.custom;
          break;
      }
    }

    return JobPostFormData(
      selectedCategory: selectedCategory,
      selectedServices: selectedServices,
      jobType: jobType,
      frequency: frequency,
      preferredDate: job.preferredDate,
      startDate: job.startDate,
      endDate: job.endDate,
      title: job.title,
      jobSize: jobSize,
      description: job.description,
      address: job.address,
      photoFiles: const [], // Note: You'll need to handle existing photos separately
    );
  }
}

@JsonSerializable()
class ApiError {
  final String message;
  final Map<String, List<String>>? errors;

  const ApiError({required this.message, this.errors});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

@JsonSerializable()
class JobListResponse {
  final int id;
  @JsonKey(name: 'homeowner_id')
  final int homeownerId;
  final String title;
  final String description;
  final String address;
  @JsonKey(name: 'job_type')
  final String jobType;
  @JsonKey(name: 'job_size')
  final String jobSize;
  @JsonKey(name: 'preferred_date')
  final DateTime? preferredDate;
  final String status;
  @JsonKey(name: 'photo_urls')
  final List<String>? photoUrls;
  final Map<String, dynamic>? category;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const JobListResponse({
    required this.id,
    required this.homeownerId,
    required this.title,
    required this.description,
    required this.address,
    required this.jobType,
    required this.jobSize,
    this.preferredDate,
    required this.status,
    this.photoUrls,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobListResponse.fromJson(Map<String, dynamic> json) =>
      _$JobListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JobListResponseToJson(this);
  // Helper method to get photo URLs
  List<String> get allPhotoUrls => photoUrls ?? [];
}
