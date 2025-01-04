class SubscriptionPlan {
  final int id;
  final String plan;
  final int frequency;
  final int bookings;
  final double pricing;
  final DateTime createdAt;

  SubscriptionPlan({
    required this.id,
    required this.plan,
    required this.frequency,
    required this.bookings,
    required this.pricing,
    required this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      plan: json['plan'],
      frequency: int.tryParse(json['frequency'].toString()) ?? 0,
      bookings: json['bookings'],
      pricing: json['pricing'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': plan,
      'frequency': frequency,
      'bookings': bookings,
      'pricing': pricing,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
