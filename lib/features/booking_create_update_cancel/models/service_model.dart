class Service {
  final int id;
  final int homeownerId;
  final int jobCategoryId;
  final String jobDescription;
  final String location;
  final String status;
  final int? rating;
  final ServiceCategory? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.homeownerId,
    required this.jobCategoryId,
    required this.jobDescription,
    required this.location,
    required this.status,
    this.rating,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse('${json['id']}') ?? 0),
      homeownerId: json['homeowner_id'] is int
          ? json['homeowner_id'] as int
          : (int.tryParse('${json['homeowner_id']}') ?? 0),
      jobCategoryId: json['job_categoryid'] is int
          ? json['job_categoryid'] as int
          : (int.tryParse('${json['job_categoryid']}') ?? 0),
      jobDescription: json['job_description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'Pending',
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse('${json['rating']}'),
      category: json['category'] != null
          ? ServiceCategory.fromJson(json['category'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // Legacy getters for backward compatibility
  String get name => jobDescription;
  String get description => jobDescription;
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
          : (int.tryParse('${json['id']}') ?? 0),
      categoryName: json['category_name'] ?? '',
      description: json['description'],
    );
  }
}
