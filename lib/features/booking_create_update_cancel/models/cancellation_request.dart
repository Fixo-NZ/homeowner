class CancellationRequest {
  final int bookingId;
  final String reason;
  final String? additionalDetails;

  CancellationRequest({
    required this.bookingId,
    required this.reason,
    this.additionalDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'reason': reason,
      if (additionalDetails != null && additionalDetails!.isNotEmpty)
        'additional_details': additionalDetails,
    };
  }
}
