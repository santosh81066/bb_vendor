import 'dart:io';

class PropertyModel {
  final int? propertyId; // Add propertyId for updates
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
  final PropertyManager? manager; // Add manager details
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyModel({
    this.propertyId,
    required this.propertyName,
    required this.category,
    this.propertyImage,
    required this.address1,
    required this.address2,
    required this.location,
    required this.state,
    required this.city,
    required this.pincode,
    required this.startTime,
    required this.endTime,
    this.manager,
    this.createdAt,
    this.updatedAt,
  });

  PropertyModel copyWith({
    int? propertyId,
    String? propertyName,
    String? category,
    File? propertyImage,
    String? address1,
    String? address2,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? startTime,
    String? endTime,
    PropertyManager? manager,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      category: category ?? this.category,
      propertyImage: propertyImage ?? this.propertyImage,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      location: location ?? this.location,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      manager: manager ?? this.manager,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create a partial copy for updates (only non-null values are updated)
  PropertyModel partialUpdate({
    String? propertyName,
    String? category,
    File? propertyImage,
    String? address1,
    String? address2,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? startTime,
    String? endTime,
    PropertyManager? manager,
  }) {
    return PropertyModel(
      propertyId: propertyId,
      propertyName: propertyName?.isNotEmpty == true ? propertyName! : this.propertyName,
      category: category?.isNotEmpty == true ? category! : this.category,
      propertyImage: propertyImage ?? this.propertyImage,
      address1: address1?.isNotEmpty == true ? address1! : this.address1,
      address2: address2?.isNotEmpty == true ? address2! : this.address2,
      location: location?.isNotEmpty == true ? location! : this.location,
      state: state?.isNotEmpty == true ? state! : this.state,
      city: city?.isNotEmpty == true ? city! : this.city,
      pincode: pincode?.isNotEmpty == true ? pincode! : this.pincode,
      startTime: startTime?.isNotEmpty == true ? startTime! : this.startTime,
      endTime: endTime?.isNotEmpty == true ? endTime! : this.endTime,
      manager: manager ?? this.manager,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PropertyModel &&
        other.propertyId == propertyId &&
        other.propertyName == propertyName &&
        other.category == category &&
        other.propertyImage == propertyImage &&
        other.address1 == address1 &&
        other.address2 == address2 &&
        other.location == location &&
        other.state == state &&
        other.city == city &&
        other.pincode == pincode &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.manager == manager;
  }

  @override
  int get hashCode {
    return Object.hash(
      propertyId,
      propertyName,
      category,
      propertyImage,
      address1,
      address2,
      location,
      state,
      city,
      pincode,
      startTime,
      endTime,
      manager,
    );
  }

  @override
  String toString() {
    return 'PropertyModel('
        'propertyId: $propertyId, '
        'propertyName: $propertyName, '
        'category: $category, '
        'propertyImage: $propertyImage, '
        'address1: $address1, '
        'address2: $address2, '
        'location: $location, '
        'state: $state, '
        'city: $city, '
        'pincode: $pincode, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'manager: $manager'
        ')';
  }

  // Enhanced validation methods
  bool get isValid {
    return propertyName.isNotEmpty &&
        category.isNotEmpty &&
        address1.isNotEmpty &&
        location.isNotEmpty &&
        state.isNotEmpty &&
        city.isNotEmpty &&
        pincode.isNotEmpty &&
        startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        (manager?.isValid ?? true); // Manager is optional but if present, must be valid
  }

  // Validate specific fields for partial updates
  Map<String, String> validateForUpdate() {
    final errors = <String, String>{};

    if (propertyName.isEmpty) {
      errors['propertyName'] = 'Property name is required';
    } else if (propertyName.length < 3) {
      errors['propertyName'] = 'Property name must be at least 3 characters';
    }

    if (address1.isEmpty) {
      errors['address1'] = 'Primary address is required';
    }

    if (location.isEmpty) {
      errors['location'] = 'Location is required';
    }

    if (state.isEmpty) {
      errors['state'] = 'State is required';
    }

    if (city.isEmpty) {
      errors['city'] = 'City is required';
    }

    if (pincode.isEmpty) {
      errors['pincode'] = 'Pincode is required';
    } else if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      errors['pincode'] = 'Pincode must be 6 digits';
    }

    if (startTime.isEmpty) {
      errors['startTime'] = 'Start time is required';
    }

    if (endTime.isEmpty) {
      errors['endTime'] = 'End time is required';
    }

    // Validate manager if present
    if (manager != null && !manager!.isValid) {
      errors.addAll(manager!.validate());
    }

    return errors;
  }

  String get fullAddress {
    final parts = [address1, address2, city, state, pincode]
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  // Check if property is new (no ID)
  bool get isNew => propertyId == null;

  // Check if property has been modified recently (within last 24 hours)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);
    return difference.inHours < 24;
  }

  // Convert to JSON for API calls (enhanced for updates)
  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final json = <String, dynamic>{
      'propertyName': propertyName,
      'category': category,
      'address': address1,
      'address2': address2,
      'location': location,
      'state': state,
      'city': city,
      'pincode': pincode,
      'startTime': startTime,
      'endTime': endTime,
    };

    // Include propertyId for updates
    if (forUpdate && propertyId != null) {
      json['propertyId'] = propertyId;
    }

    // Include manager details if present
    if (manager != null) {
      json['manager'] = manager!.toJson();
    }

    // Include timestamps
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      json['updatedAt'] = updatedAt!.toIso8601String();
    }

    return json;
  }

  // Create JSON for partial updates (only changed fields)
  Map<String, dynamic> toUpdateJson(PropertyModel original) {
    final updates = <String, dynamic>{};

    if (propertyId != null) {
      updates['propertyId'] = propertyId;
    }

    if (propertyName != original.propertyName) {
      updates['propertyName'] = propertyName;
    }
    if (category != original.category) {
      updates['category'] = category;
    }
    if (address1 != original.address1) {
      updates['address'] = address1;
    }
    if (address2 != original.address2) {
      updates['address2'] = address2;
    }
    if (location != original.location) {
      updates['location'] = location;
    }
    if (state != original.state) {
      updates['state'] = state;
    }
    if (city != original.city) {
      updates['city'] = city;
    }
    if (pincode != original.pincode) {
      updates['pincode'] = pincode;
    }
    if (startTime != original.startTime) {
      updates['startTime'] = startTime;
    }
    if (endTime != original.endTime) {
      updates['endTime'] = endTime;
    }

    // Check manager changes
    if (manager != original.manager) {
      if (manager != null) {
        updates['manager'] = manager!.toJson();
      } else {
        updates['manager'] = null; // Remove manager
      }
    }

    updates['updatedAt'] = DateTime.now().toIso8601String();

    return updates;
  }

  // Create from JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      propertyId: json['propertyId'],
      propertyName: json['propertyName'] ?? '',
      category: json['category'] ?? '',
      address1: json['address'] ?? '',
      address2: json['address2'] ?? '',
      location: json['location'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      manager: json['manager'] != null
          ? PropertyManager.fromJson(json['manager'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Create an empty instance for form initialization
  factory PropertyModel.empty() {
    return const PropertyModel(
      propertyName: '',
      category: '',
      address1: '',
      address2: '',
      location: '',
      state: '',
      city: '',
      pincode: '',
      startTime: '',
      endTime: '',
    );
  }

  // Create from existing Data model (for compatibility)
  factory PropertyModel.fromData(dynamic data) {
    return PropertyModel(
      propertyId: data.propertyId,
      propertyName: data.propertyName ?? '',
      category: data.category?.toString() ?? '',
      address1: data.address ?? '',
      address2: '', // Not available in Data model
      location: data.location ?? '',
      state: '', // Not available in Data model
      city: '', // Not available in Data model
      pincode: '', // Not available in Data model
      startTime: '', // Not available in Data model
      endTime: '', // Not available in Data model
    );
  }
}

// Enhanced PropertyManager class
class PropertyManager {
  final String name;
  final String phone;
  final String email;
  final String designation;
  final String experience;
  final File? image;

  const PropertyManager({
    required this.name,
    required this.phone,
    required this.email,
    required this.designation,
    required this.experience,
    this.image,
  });

  PropertyManager copyWith({
    String? name,
    String? phone,
    String? email,
    String? designation,
    String? experience,
    File? image,
  }) {
    return PropertyManager(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      experience: experience ?? this.experience,
      image: image ?? this.image,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        RegExp(r'^[0-9]{10}$').hasMatch(phone) &&
        email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Map<String, String> validate() {
    final errors = <String, String>{};

    if (name.isEmpty) {
      errors['managerName'] = 'Manager name is required';
    }

    if (phone.isEmpty) {
      errors['managerPhone'] = 'Manager phone is required';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      errors['managerPhone'] = 'Phone number must be 10 digits';
    }

    if (email.isEmpty) {
      errors['managerEmail'] = 'Manager email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['managerEmail'] = 'Please enter a valid email address';
    }

    return errors;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'designation': designation,
      'experience': experience,
      'hasImage': image != null,
    };
  }

  factory PropertyManager.fromJson(Map<String, dynamic> json) {
    return PropertyManager(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      designation: json['designation'] ?? '',
      experience: json['experience'] ?? '',
    );
  }

  factory PropertyManager.empty() {
    return const PropertyManager(
      name: '',
      phone: '',
      email: '',
      designation: '',
      experience: '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PropertyManager &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.designation == designation &&
        other.experience == experience;
  }

  @override
  int get hashCode {
    return Object.hash(name, phone, email, designation, experience);
  }

  @override
  String toString() {
    return 'PropertyManager(name: $name, phone: $phone, email: $email, designation: $designation, experience: $experience)';
  }
}