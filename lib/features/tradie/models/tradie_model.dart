class TradieModel {
  final int id;
  final String name;
  final String profession;
  final double rating;
  final String? avatarUrl;

  TradieModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.rating,
    this.avatarUrl,
  });

  factory TradieModel.fromJson(Map<String, dynamic> json) {
    return TradieModel(
      id: json['id'] as int,
      name: json['name'] as String,
      profession: json['profession'] as String? ?? (json['role'] as String? ?? ''),
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
      avatarUrl: json['avatar'] as String?,
    );
  }
}
