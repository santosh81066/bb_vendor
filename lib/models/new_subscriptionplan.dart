class Subscription {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<Data>? data;

  Subscription({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  factory Subscription.initial() {
    return Subscription(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      statusCode: json['statusCode'],
      success: json['success'],
      messages: json['messages']?.cast<String>(),
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Data.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'messages': messages,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }

  Subscription copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return Subscription(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}

class Data {
  final int? planId;
  final String? planName;
  final int? createdBy;
  final List<SubPlans>? subPlans;

  Data({
    this.planId,
    this.planName,
    this.createdBy,
    this.subPlans,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      planId: json['plan_id'],
      planName: json['plan_name'],
      createdBy: json['created_by'],
      subPlans: (json['sub_plans'] as List<dynamic>?)
          ?.map((item) => SubPlans.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name': planName,
      'created_by': createdBy,
      'sub_plans': subPlans?.map((item) => item.toJson()).toList(),
    };
  }

  Data copyWith({
    int? planId,
    String? planName,
    int? createdBy,
    List<SubPlans>? subPlans,
  }) {
    return Data(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      createdBy: createdBy ?? this.createdBy,
      subPlans: subPlans ?? this.subPlans,
    );
  }
}

class SubPlans {
  final int? subPlanId;
  final String? subPlanName;
  final String? frequency;
  final int? numBookings;
  final String? price;

  SubPlans({
    this.subPlanId,
    this.subPlanName,
    this.frequency,
    this.numBookings,
    this.price,
  });

  factory SubPlans.fromJson(Map<String, dynamic> json) {
    return SubPlans(
      subPlanId: json['sub_plan_id'],
      subPlanName: json['sub_plan_name'],
      frequency: json['frequency'],
      numBookings: json['num_bookings'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_plan_id': subPlanId,
      'sub_plan_name': subPlanName,
      'frequency': frequency,
      'num_bookings': numBookings,
      'price': price,
    };
  }

  SubPlans copyWith({
    int? subPlanId,
    String? subPlanName,
    String? frequency,
    int? numBookings,
    String? price,
  }) {
    return SubPlans(
      subPlanId: subPlanId ?? this.subPlanId,
      subPlanName: subPlanName ?? this.subPlanName,
      frequency: frequency ?? this.frequency,
      numBookings: numBookings ?? this.numBookings,
      price: price ?? this.price,
    );
  }
}

// class SubscriptionPlan {
//   final int id;
//   final String plan;
//   final int frequency;
//   final int bookings;
//   final double pricing;
//   final DateTime createdAt;

//   SubscriptionPlan({
//     required this.id,
//     required this.plan,
//     required this.frequency,
//     required this.bookings,
//     required this.pricing,
//     required this.createdAt,
//   });

//   factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
//     return SubscriptionPlan(
//       id: json['id'],
//       plan: json['plan'],
//       frequency: int.tryParse(json['frequency'].toString()) ?? 0,
//       bookings: json['bookings'],
//       pricing: json['pricing'].toDouble(),
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'plan': plan,
//       'frequency': frequency,
//       'bookings': bookings,
//       'pricing': pricing,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
