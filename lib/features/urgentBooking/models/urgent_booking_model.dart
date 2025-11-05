class UrgentBookingModel {
  final int id;
  final int? homeownerId;
  final int? jobId;
  final int? tradieId;
  final String status;
  final String? priorityLevel;
  final DateTime? requestedAt;
  final DateTime? respondedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UrgentBookingModel({
    required this.id,
    this.homeownerId,
    this.jobId,
    this.tradieId,
    required this.status,
    this.priorityLevel,
    this.requestedAt,
    this.respondedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory UrgentBookingModel.fromJson(Map<String, dynamic> json) {
    // Accept either plain booking object or wrapped { booking: {...} }
    final Map<String, dynamic> data =
        json.containsKey('booking') && json['booking'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['booking'] as Map<String, dynamic>)
            : json;

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return UrgentBookingModel(
      id: parseInt(data['id']) ?? 0,
      homeownerId: parseInt(data['homeowner_id']) ?? parseInt(data['homeowner']),
      jobId: parseInt(data['job_id']) ?? parseInt(data['job']),
      tradieId: parseInt(data['tradie_id']) ?? parseInt(data['tradie']),
      status: (data['status']?.toString() ?? 'pending'),
      priorityLevel: data['priority_level']?.toString(),
      requestedAt: parseDt(data['requested_at']) ?? parseDt(data['created_at']),
      respondedAt: parseDt(data['responded_at']),
      notes: data['notes']?.toString(),
      createdAt: parseDt(data['created_at']),
      updatedAt: parseDt(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeowner_id': homeownerId,
      'job_id': jobId,
      'tradie_id': tradieId,
      'status': status,
      'priority_level': priorityLevel,
      'requested_at': requestedAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
