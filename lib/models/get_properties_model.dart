class Property {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  Property({this.statusCode, this.success, this.messages, this.data});

  Property.fromJson(Map<String, dynamic> json) {
  statusCode = json['statusCode'];
  success = json['success'];
  messages = json['messages']?.cast<String>() ?? [];
  if (json['data'] != null) {
    data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
  } else {
    data = [];
  }
}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Property copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return Property(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  static Property initial() {
    return Property(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }
}

class Data {
  int? propertyId;
  String? propertyName;
  String? address;
  String? location;
  String? coverPic;
  int? category;
  List<Hall>? halls;

  Data({
    this.propertyId,
    this.propertyName,
    this.address,
    this.location,
    this.coverPic,
    this.category,
    this.halls,
  });

  Data.fromJson(Map<String, dynamic> json) {
    propertyId = json['property_id'];
    propertyName = json['propertyName'];
    address = json['address'];
    location = json['location'];
    coverPic = json['cover_pic'];
    category = json['category'];
    if (json['halls'] != null) {
      halls = List<Hall>.from(json['halls'].map((v) => Hall.fromJson(v)));
    } else {
      halls = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['property_id'] = propertyId;
    data['propertyName'] = propertyName;
    data['address'] = address;
    data['location'] = location;
    data['cover_pic'] = coverPic;
    data['category'] = category;
    if (halls != null) {
      data['halls'] = halls!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Data copyWith({
    int? propertyId,
    String? propertyName,
    String? address,
    String? location,
    String? coverPic,
    int? category,
    List<Hall>? halls,
  }) {
    return Data(
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      address: address ?? this.address,
      location: location ?? this.location,
      coverPic: coverPic ?? this.coverPic,
      category: category ?? this.category,
      halls: halls ?? this.halls,
    );
  }

  static Data initial() {
    return Data(
      propertyId: 0,
      propertyName: "",
      address: "",
      location: "",
      coverPic: "",
      category: 0,
      halls: [],
    );
  }
}

class Hall {
  int? hallId;
  String? hallName;
  int? capacity;

  Hall({this.hallId, this.hallName, this.capacity});

  Hall.fromJson(Map<String, dynamic> json) {
    hallId = json['hall_id'];
    hallName = json['hall_name'];
    capacity = json['capacity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hall_id'] = hallId;
    data['hall_name'] = hallName;
    data['capacity'] = capacity;
    return data;
  }

  Hall copyWith({
    int? hallId,
    String? hallName,
    int? capacity,
  }) {
    return Hall(
      hallId: hallId ?? this.hallId,
      hallName: hallName ?? this.hallName,
      capacity: capacity ?? this.capacity,
    );
  }

  static Hall initial() {
    return Hall(
      hallId: 0,
      hallName: "",
      capacity: 0,
    );
  }
}
