class Service {
  final int id;
  final String name;
  final String description;
  final String? icon;

  Service({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: json['icon'],
    );
  }
}
