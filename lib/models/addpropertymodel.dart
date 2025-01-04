// class PropertyModel{
//   final String? username;
//   final String? email;
//   final String? password;
//   final String? mobileno;
//   final String? gender;
//   final String? filePath;

//   PropertyModel({
//     this.username,
//     this.email,
//     this.password,
//     this.mobileno,
//     this.gender ,
//     this.filePath ,
//   });

//   PropertyModel copyWith({
//     String? username,
//     String? email,
//     String? password,
//     String? mobileno,
//     String? gender,
//     String? filePath,
//   }) {
//     return PropertyModel(
//       username: username ?? this.username,
//       email: email ?? this.email,
//       password: password ?? this.password,
//       mobileno: mobileno ?? this.mobileno,
//       gender: gender ?? this.gender,
//       filePath: filePath ?? this.filePath,
//     );
//   }

//   PropertyModel clear() {
//     return PropertyModel(
//       username: null,
//       email: null,
//       password: null,
//       mobileno: null,
//       gender: null,
//       filePath: null,
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

class PropertyModel {
  final String propertyName;
  final String category;
  final File? propertyImage;
  final String address1;
  final String address2;
  final String location;
  final String state;
  final String city;
  final String pincode;
  final String startTime;
  final String endTime;

  PropertyModel({
    required this.propertyName,
    required this.category,
    required this.propertyImage,
    required this.address1,
    required this.address2,
    required this.location,
    required this.state,
    required this.city,
    required this.pincode,
    required this.startTime,
    required this.endTime,
  });
  PropertyModel copyWith({
    String? propertyName,
    String? category,
    File? propertyImage,
    String? address1,
    String? address2,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? starttime,
    String? endtime,
  }) {
    return PropertyModel(
        propertyName: propertyName ?? this.propertyName,
        category: category ?? this.category,
        propertyImage: propertyImage ?? this.propertyImage,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        location: location ?? this.location,
        state: state ?? this.state,
        city: city ?? this.city,
        pincode: pincode ?? this.pincode,
        startTime: startTime,
        endTime: endTime);
  }
}
