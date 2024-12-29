class AdminAuth {
  int? statusCode;
  bool? success;
  List<String>? messages;
  Data? data;

  AdminAuth({this.statusCode, this.success, this.messages, this.data});

  AdminAuth.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = List<String>.from(json['messages']);
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  // CopyWith method
  AdminAuth copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    Data? data,
  }) {
    return AdminAuth(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  // Initial method
  factory AdminAuth.initial() {
    return AdminAuth(
      statusCode: 0,
      success: false,
      messages: [],
      data: Data.initial(),
    );
  }
}

class Data {
  int? userId;
  String? username;
  String? email;
  String? address;
  String? location;
  String? userRole;
  bool? userStatus;
  String? mobileNo; // Changed to String
  String? accessToken;
  int? accessTokenExpiresAt;
  String? refreshToken;
  int? refreshTokenExpiresAt;
  String? profilePic; // Added profile_pic key

  Data({
    this.userId,
    this.username,
    this.email,
    this.address,
    this.location,
    this.userRole,
    this.userStatus,
    this.mobileNo,
    this.accessToken,
    this.accessTokenExpiresAt,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.profilePic,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    email = json['email'];
    address = json['address'];
    location = json['location'];
    userRole = json['user_role'];
    userStatus = json['user_status'];
    mobileNo = json['mobile_no']?.toString(); // Ensure mobile number is a String
    accessToken = json['access_token'];
    accessTokenExpiresAt = json['access_token_expires_at'];
    refreshToken = json['refresh_token'];
    refreshTokenExpiresAt = json['refresh_token_expires_at'];
    profilePic = json['profile_pic']; // Parse profile_pic from JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['email'] = email;
    data['address'] = address;
    data['location'] = location;
    data['user_role'] = userRole;
    data['user_status'] = userStatus;
    data['mobile_no'] = mobileNo;
    data['access_token'] = accessToken;
    data['access_token_expires_at'] = accessTokenExpiresAt;
    data['refresh_token'] = refreshToken;
    data['refresh_token_expires_at'] = refreshTokenExpiresAt;
    data['profile_pic'] = profilePic; // Add profile_pic to JSON
    return data;
  }

  // CopyWith method
  Data copyWith({
    int? userId,
    String? username,
    String? email,
    String? address,
    String? location,
    String? userRole,
    bool? userStatus,
    String? mobileNo,
    String? accessToken,
    int? accessTokenExpiresAt,
    String? refreshToken,
    int? refreshTokenExpiresAt,
    String? profilePic,
  }) {
    return Data(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      address: address ?? this.address,
      location: location ?? this.location,
      userRole: userRole ?? this.userRole,
      userStatus: userStatus ?? this.userStatus,
      mobileNo: mobileNo ?? this.mobileNo,
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      profilePic: profilePic ?? this.profilePic, // Add profilePic to copyWith
    );
  }

  // Initial method
  factory Data.initial() {
    return Data(
      userId: 0,
      username: '',
      email: '',
      address: '',
      location: '',
      userRole: '',
      userStatus: false,
      mobileNo: '',
      accessToken: '',
      accessTokenExpiresAt: 0,
      refreshToken: '',
      refreshTokenExpiresAt: 0,
      profilePic: '', // Initialize profilePic with an empty string
    );
  }
}
