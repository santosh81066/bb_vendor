import 'dart:io';

class RegistrationState {
  final File? profileImage;
  // final File? propertyImage;

  final String username;
  final String email;
  final String password;
  final String contactNumber;
  // final String address1;
  // final String address2;
  // final String state;
  // final String city;
  // final String pincode;
  // final String location;

  RegistrationState({
    this.profileImage,
    // this.propertyImage,
    this.username = '',
    this.email = '',
    this.password = '',
    this.contactNumber = '',
    // this.address1 = '',
    // this.address2 = '',
    // this.state = '',
    // this.city = '',
    // this.pincode = '',
    // this.location = '',
  });

  RegistrationState copyWith({
    File? profileImage,
    File? propertyImage,
    String? username,
    String? email,
    String? password,
    String? contactNumber,
    String? address1,
    String? address2,
    String? state,
    String? city,
    String? pincode,
    String? location,
  }) {
    return RegistrationState(
      profileImage: profileImage ?? this.profileImage,
      // propertyImage: propertyImage ?? this.propertyImage,
      
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      contactNumber: contactNumber ?? this.contactNumber,
      // address1: address1 ?? this.address1,
      // address2: address2 ?? this.address2,
      // state: state ?? this.state,
      // city: city ?? this.city,
      // pincode: pincode ?? this.pincode,
      // location: location ?? this.location,
    );
  }

}