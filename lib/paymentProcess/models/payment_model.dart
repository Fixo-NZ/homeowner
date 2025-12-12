class PaymentModel {
  final String? cardNumber;
  final String? cardType;
  final double hourlyRate;
  final int duration;
  final double subtotal;
  final double serviceFee;
  final double estimatedTotal;
  final bool hasPaymentMethod;

  PaymentModel({
    this.cardNumber,
    this.cardType,
    required this.hourlyRate,
    required this.duration,
    required this.subtotal,
    required this.serviceFee,
    required this.estimatedTotal,
    required this.hasPaymentMethod,
  });
}