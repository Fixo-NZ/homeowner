class TradieFilter {
  final String tradeType;
  final String preferredTime;
  final double radiusKm;
  final int budget;

  const TradieFilter({
    this.tradeType = 'Any category',
    this.preferredTime = 'Anytime',
    this.radiusKm = 25.0,
    this.budget = 550,
  });

  TradieFilter copyWith({
    String? tradeType,
    String? preferredTime,
    double? radiusKm,
    int? budget,
  }) {
    return TradieFilter(
      tradeType: tradeType ?? this.tradeType,
      preferredTime: preferredTime ?? this.preferredTime,
      radiusKm: radiusKm ?? this.radiusKm,
      budget: budget ?? this.budget,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (tradeType.isNotEmpty && tradeType != 'Any category')
        'trade_type': tradeType,
      if (preferredTime.isNotEmpty && preferredTime != 'Anytime')
        'preferred_time': preferredTime,
      'radius_km': radiusKm,
      'budget': budget,
    };
  }
}
