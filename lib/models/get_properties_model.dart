class Property {
  final int id;
  final String propertyPic;
  final String propertyName;
  final int category;
  final String address1;
  final String address2;
  final int reviewCount;
  final double averageRating;
  final String location;
  final String state;
  final String city;
  final String pincode;
  final String activationStatus;
  final String startTime;
  final String endTime;

  Property({
    required this.id,
    required this.propertyPic,
    required this.propertyName,
    required this.category,
    required this.address1,
    required this.address2,
    required this.reviewCount,
    required this.averageRating,
    required this.location,
    required this.state,
    required this.city,
    required this.pincode,
    required this.activationStatus,
    required this.startTime,
    required this.endTime,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      propertyPic: json['property_pic'],
      propertyName: json['property_name'],
      category: json['category'],
      address1: json['address_1'],
      address2: json['address_2'],
      reviewCount: json['review_count'],
      averageRating: (json['average_rating'] as num).toDouble(),
      location: json['location'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      activationStatus: json['activation_status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_pic': propertyPic,
      'property_name': propertyName,
      'category': category,
      'address_1': address1,
      'address_2': address2,
      'review_count': reviewCount,
      'average_rating': averageRating,
      'location': location,
      'state': state,
      'city': city,
      'pincode': pincode,
      'activation_status': activationStatus,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
