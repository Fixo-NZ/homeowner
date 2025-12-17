class PaymentTransaction {
  final String customerName;
  final String serviceType;
  final String serviceDescription;
  final String date;
  final String location;
  final double totalPayment;
  final String status;
  final int? bookingId;  // Store booking ID for payment processing
  final String? paymentMethodId;  // Store saved card's payment method ID

  PaymentTransaction({
    required this.customerName,
    required this.serviceType,
    required this.serviceDescription,
    required this.date,
    required this.location,
    required this.totalPayment,
    required this.status,
    this.bookingId,
    this.paymentMethodId,
  });
}