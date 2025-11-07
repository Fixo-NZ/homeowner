import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:tradie/core/constants/api_constants.dart';
import 'package:tradie/core/services/photo_service.dart';

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
  final int homeownerId;

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
    this.homeownerId = 1,
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
  final List<Map<String, dynamic>>? services;
  final List<Map<String, dynamic>>? photos;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const JobPostResponse({
    required this.id,
    required this.homeownerId,
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
    this.services,
    this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPostResponse.fromJson(Map<String, dynamic> json) =>
      _$JobPostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JobPostResponseToJson(this);
}

// ✅ REMOVED @JsonSerializable() - This class doesn't need JSON serialization
class JobPostFormData {
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

  const JobPostFormData({
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
      homeownerId: 1, //change 1 to user id after authentication works
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