class TradieRequest {
  final int id;
  final int? homeownerId;
  final String title;
  final String description; // descrption or job description
  final String? location;
  final String status; // pending, active, completed, cancelled
  final String jobType; // urgent, standard, recurring
  final double? budget;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final JobCategory? category;

  TradieRequest({
    required this.id,
    this.homeownerId,
    required this.title,
    required this.description,
    this.location,
    required this.status,
    required this.jobType,
    this.budget,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory TradieRequest.fromJson(Map<String, dynamic> json) {
    // Accept different naming possibilities coming from backend change some if needed
    final data = json;
    final id = data['id'] is int
        ? data['id'] as int
        : int.parse('${data['id']}');
    final title = data['title'] ?? data['job_description'] ?? '';
    final desc = data['description'] ?? data['job_description'] ?? '';
    final status = (data['status'] ?? 'pending').toString();
    final jobType = (data['job_type'] ?? data['urgency'] ?? 'standard')
        .toString();
    double? budget;
    if (data['budget'] != null) {
      try {
        budget = double.tryParse(data['budget'].toString());
      } catch (_) {
        budget = null;
      }
    }

    JobCategory? category;
    if (data['category'] is Map<String, dynamic>) {
      category = JobCategory.fromJson(
        Map<String, dynamic>.from(data['category']),
      );
    } else if (data['job_category'] is Map<String, dynamic>) {
      category = JobCategory.fromJson(
        Map<String, dynamic>.from(data['job_category']),
      );
    }

    DateTime? createdAt;
    if (data['created_at'] != null) {
      createdAt = DateTime.tryParse(data['created_at'].toString());
    }

    DateTime? updatedAt;
    if (data['updated_at'] != null) {
      updatedAt = DateTime.tryParse(data['updated_at'].toString());
    }

    return TradieRequest(
      id: id,
      homeownerId: data['homeowner_id'] is int
          ? data['homeowner_id'] as int
          : (data['homeowner_id'] == null
          ? null
          : int.tryParse('${data['homeowner_id']}')),
      title: title,
      description: desc,
      location: data['location']?.toString(),
      status: status,
      jobType: jobType,
      budget: budget,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category,
    );
  }
}

class JobCategory {
  final int id;
  final String name;

  JobCategory({required this.id, required this.name});

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: (json['name'] ?? json['category_name'] ?? '').toString(),
    );
  }
}
