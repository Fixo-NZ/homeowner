class ServiceModel {
  final int jobId;
  final int homeownerId;
  final int jobCategoryId;
  final String jobDescription;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? rating;
  final ServiceCategory? category;
  final Homeowner? homeowner;

  ServiceModel({
    required this.jobId,
    required this.homeownerId,
    required this.jobCategoryId,
    required this.jobDescription,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.category,
    this.homeowner,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      jobId: json['job_id'] is int 
          ? json['job_id'] as int 
          : int.parse('${json['job_id']}'),
      homeownerId: json['homeowner_id'] is int 
          ? json['homeowner_id'] as int 
          : int.parse('${json['homeowner_id']}'),
      jobCategoryId: json['job_categoryid'] is int 
          ? json['job_categoryid'] as int 
          : int.parse('${json['job_categoryid']}'),
      jobDescription: json['job_description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      rating: json['rating'] is int 
          ? json['rating'] as int 
          : int.tryParse('${json['rating']}'),
      category: json['category'] != null 
          ? ServiceCategory.fromJson(json['category']) 
          : null,
      homeowner: json['homeowner'] != null 
          ? Homeowner.fromJson(json['homeowner']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'homeowner_id': homeownerId,
      'job_categoryid': jobCategoryId,
      'job_description': jobDescription,
      'location': location,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
      'category': category?.toJson(),
      'homeowner': homeowner?.toJson(),
    };
  }

  ServiceModel copyWith({
    int? jobId,
    int? homeownerId,
    int? jobCategoryId,
    String? jobDescription,
    String? location,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rating,
    ServiceCategory? category,
    Homeowner? homeowner,
  }) {
    return ServiceModel(
      jobId: jobId ?? this.jobId,
      homeownerId: homeownerId ?? this.homeownerId,
      jobCategoryId: jobCategoryId ?? this.jobCategoryId,
      jobDescription: jobDescription ?? this.jobDescription,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      homeowner: homeowner ?? this.homeowner,
    );
  }
}

class ServiceCategory {
  final int id;
  final String categoryName;
  final String? description;

  ServiceCategory({
    required this.id,
    required this.categoryName,
    this.description,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse('${json['id']}'),
      categoryName: json['category_name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'description': description,
    };
  }
}

class Homeowner {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  Homeowner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });

  factory Homeowner.fromJson(Map<String, dynamic> json) {
    return Homeowner(
      id: json['id'] is int 
          ? json['id'] as int 
          : int.parse('${json['id']}'),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }

  String get fullName => '$firstName $lastName';
}
