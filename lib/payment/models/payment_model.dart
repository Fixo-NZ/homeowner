class PaymentModel {
  final String id;
  final int serviceId;
  final double amount;
  final String currency;
  final String status; // 'pending','confirmed','failed'
  final DateTime createdAt;
  final Map<String, dynamic>? providerPayload;

  PaymentModel({
    required this.id,
    required this.serviceId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.providerPayload,
  });

    factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'].toString(),
        serviceId: json['service_id'] ?? json['serviceId'] ?? 0,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] ?? 'AUD',
        status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      providerPayload: json['provider_payload'] is Map ? Map<String, dynamic>.from(json['provider_payload']) :
        (json['providerPayload'] is Map ? Map<String, dynamic>.from(json['providerPayload']) : null),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_id': serviceId,
        'amount': amount,
        'currency': currency,
        'status': status,
      'created_at': createdAt.toIso8601String(),
      'provider_payload': providerPayload,
      };
}
