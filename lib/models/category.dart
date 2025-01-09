class Category {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  Category({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  Category.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
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

  // Initial method
  factory Category.initial() {
    return Category(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  // CopyWith method
  Category copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return Category(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}

class Data {
  int? id;
  String? name;

  Data({this.id, this.name});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  // Initial method
  factory Data.initial() {
    return Data(
      id: 0,
      name: "",
    );
  }

  // CopyWith method
  Data copyWith({
    int? id,
    String? name,
  }) {
    return Data(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
