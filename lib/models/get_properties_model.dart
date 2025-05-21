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
  int? vendorId; // Added vendor_id field
  List<Hall>? halls;

  Data({
    this.propertyId,
    this.propertyName,
    this.address,
    this.location,
    this.coverPic,
    this.category,
    this.vendorId, // Added to constructor
    this.halls,
  });

  Data.fromJson(Map<String, dynamic> json) {
    propertyId = json['property_id'];
    propertyName = json['propertyName'];
    address = json['address'];
    location = json['location'];
    coverPic = json['cover_pic'];
    category = json['category'];
    vendorId = json['vendor_id']; // Parse vendor_id
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
    data['vendor_id'] = vendorId; // Add to JSON output
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
    int? vendorId, // Added to copyWith
    List<Hall>? halls,
  }) {
    return Data(
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      address: address ?? this.address,
      location: location ?? this.location,
      coverPic: coverPic ?? this.coverPic,
      category: category ?? this.category,
      vendorId: vendorId ?? this.vendorId, // Use in copyWith
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
      vendorId: 0, // Initial value for vendorId
      halls: [],
    );
  }
}

class Hall {
  int? hallId;
  int? propertyId; // Added property_id field
  String? name; // Using 'name' as in the response instead of 'hallName'
  int? allowOutsideDecorators; // Added field
  int? allowOutsideDj; // Added field
  int? outsideFood; // Added field
  int? allowAlcohol; // Added field
  int? valetParking; // Added field
  String? foodtype; // Added field
  int? capacity; // Added field
  int? parkingCapacity; // Added field
  int? floatingCapacity; // Added field
  int? price; // Added field
  int? emergencyExits; // Added field
  int? staffCount; // Added field
  int? cleaningStaff; // Added field
  String? securityLevel; // Added field
  int? securityCount; // Added field
  int? cctv; // Added field
  int? fireAlarm; // Added field
  int? soundSystem; // Added field
  String? soundSystemDetails; // Added field
  String? lightingSystemDetails; // Added field
  int? wifiAvailable; // Added field
  int? projectorAvailable; // Added field
  int? microphoneAvailable; // Added field
  int? cleaningCost; // Added field
  int? securityCost; // Added field
  int? decorCost; // Added field
  int? additionalServicesCost; // Added field
  List<Slot>? slots;
  List<HallImage>? images;

  Hall({
    this.hallId,
    this.propertyId,
    this.name,
    this.allowOutsideDecorators,
    this.allowOutsideDj,
    this.outsideFood,
    this.allowAlcohol,
    this.valetParking,
    this.foodtype,
    this.capacity,
    this.parkingCapacity,
    this.floatingCapacity,
    this.price,
    this.emergencyExits,
    this.staffCount,
    this.cleaningStaff,
    this.securityLevel,
    this.securityCount,
    this.cctv,
    this.fireAlarm,
    this.soundSystem,
    this.soundSystemDetails,
    this.lightingSystemDetails,
    this.wifiAvailable,
    this.projectorAvailable,
    this.microphoneAvailable,
    this.cleaningCost,
    this.securityCost,
    this.decorCost,
    this.additionalServicesCost,
    this.slots,
    this.images,
  });

  Hall.fromJson(Map<String, dynamic> json) {
    hallId = json['hall_id'];
    propertyId = json['property_id'];
    name = json['name'];
    allowOutsideDecorators = json['allow_outside_decorators'];
    allowOutsideDj = json['allow_outside_dj'];
    outsideFood = json['outside_food'];
    allowAlcohol = json['allow_alcohol'];
    valetParking = json['valet_parking'];
    foodtype = json['foodtype'];
    capacity = json['capacity'];
    parkingCapacity = json['parking_capacity'];
    floatingCapacity = json['floating_capacity'];
    price = json['price'];
    emergencyExits = json['emergency_exits'];
    staffCount = json['staff_count'];
    cleaningStaff = json['cleaning_staff'];
    securityLevel = json['security_level'];
    securityCount = json['security_count'];
    cctv = json['cctv'];
    fireAlarm = json['fire_alarm'];
    soundSystem = json['sound_system'];
    soundSystemDetails = json['sound_system_details'];
    lightingSystemDetails = json['lighting_system_details'];
    wifiAvailable = json['wifi_available'];
    projectorAvailable = json['projector_available'];
    microphoneAvailable = json['microphone_available'];
    cleaningCost = json['cleaning_cost'];
    securityCost = json['security_cost'];
    decorCost = json['decor_cost'];
    additionalServicesCost = json['additional_services_cost'];

    // Parse slots array
    if (json['slots'] != null) {
      slots = List<Slot>.from(json['slots'].map((v) => Slot.fromJson(v)));
    } else {
      slots = [];
    }

    // Parse images array
    if (json['images'] != null) {
      images = List<HallImage>.from(
          json['images'].map((v) => HallImage.fromJson(v)));
    } else {
      images = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hall_id'] = hallId;
    data['property_id'] = propertyId;
    data['name'] = name;
    data['allow_outside_decorators'] = allowOutsideDecorators;
    data['allow_outside_dj'] = allowOutsideDj;
    data['outside_food'] = outsideFood;
    data['allow_alcohol'] = allowAlcohol;
    data['valet_parking'] = valetParking;
    data['foodtype'] = foodtype;
    data['capacity'] = capacity;
    data['parking_capacity'] = parkingCapacity;
    data['floating_capacity'] = floatingCapacity;
    data['price'] = price;
    data['emergency_exits'] = emergencyExits;
    data['staff_count'] = staffCount;
    data['cleaning_staff'] = cleaningStaff;
    data['security_level'] = securityLevel;
    data['security_count'] = securityCount;
    data['cctv'] = cctv;
    data['fire_alarm'] = fireAlarm;
    data['sound_system'] = soundSystem;
    data['sound_system_details'] = soundSystemDetails;
    data['lighting_system_details'] = lightingSystemDetails;
    data['wifi_available'] = wifiAvailable;
    data['projector_available'] = projectorAvailable;
    data['microphone_available'] = microphoneAvailable;
    data['cleaning_cost'] = cleaningCost;
    data['security_cost'] = securityCost;
    data['decor_cost'] = decorCost;
    data['additional_services_cost'] = additionalServicesCost;

    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Hall copyWith({
    int? hallId,
    int? propertyId,
    String? name,
    int? allowOutsideDecorators,
    int? allowOutsideDj,
    int? outsideFood,
    int? allowAlcohol,
    int? valetParking,
    String? foodtype,
    int? capacity,
    int? parkingCapacity,
    int? floatingCapacity,
    int? price,
    int? emergencyExits,
    int? staffCount,
    int? cleaningStaff,
    String? securityLevel,
    int? securityCount,
    int? cctv,
    int? fireAlarm,
    int? soundSystem,
    String? soundSystemDetails,
    String? lightingSystemDetails,
    int? wifiAvailable,
    int? projectorAvailable,
    int? microphoneAvailable,
    int? cleaningCost,
    int? securityCost,
    int? decorCost,
    int? additionalServicesCost,
    List<Slot>? slots,
    List<HallImage>? images,
  }) {
    return Hall(
      hallId: hallId ?? this.hallId,
      propertyId: propertyId ?? this.propertyId,
      name: name ?? this.name,
      allowOutsideDecorators: allowOutsideDecorators ?? this.allowOutsideDecorators,
      allowOutsideDj: allowOutsideDj ?? this.allowOutsideDj,
      outsideFood: outsideFood ?? this.outsideFood,
      allowAlcohol: allowAlcohol ?? this.allowAlcohol,
      valetParking: valetParking ?? this.valetParking,
      foodtype: foodtype ?? this.foodtype,
      capacity: capacity ?? this.capacity,
      parkingCapacity: parkingCapacity ?? this.parkingCapacity,
      floatingCapacity: floatingCapacity ?? this.floatingCapacity,
      price: price ?? this.price,
      emergencyExits: emergencyExits ?? this.emergencyExits,
      staffCount: staffCount ?? this.staffCount,
      cleaningStaff: cleaningStaff ?? this.cleaningStaff,
      securityLevel: securityLevel ?? this.securityLevel,
      securityCount: securityCount ?? this.securityCount,
      cctv: cctv ?? this.cctv,
      fireAlarm: fireAlarm ?? this.fireAlarm,
      soundSystem: soundSystem ?? this.soundSystem,
      soundSystemDetails: soundSystemDetails ?? this.soundSystemDetails,
      lightingSystemDetails: lightingSystemDetails ?? this.lightingSystemDetails,
      wifiAvailable: wifiAvailable ?? this.wifiAvailable,
      projectorAvailable: projectorAvailable ?? this.projectorAvailable,
      microphoneAvailable: microphoneAvailable ?? this.microphoneAvailable,
      cleaningCost: cleaningCost ?? this.cleaningCost,
      securityCost: securityCost ?? this.securityCost,
      decorCost: decorCost ?? this.decorCost,
      additionalServicesCost: additionalServicesCost ?? this.additionalServicesCost,
      slots: slots ?? this.slots,
      images: images ?? this.images,
    );
  }

  static Hall initial() {
    return Hall(
      hallId: 0,
      propertyId: 0,
      name: "",
      allowOutsideDecorators: 0,
      allowOutsideDj: 0,
      outsideFood: 0,
      allowAlcohol: 0,
      valetParking: 0,
      foodtype: "",
      capacity: 0,
      parkingCapacity: 0,
      floatingCapacity: 0,
      price: 0,
      emergencyExits: 0,
      staffCount: 0,
      cleaningStaff: 0,
      securityLevel: "",
      securityCount: 0,
      cctv: 0,
      fireAlarm: 0,
      soundSystem: 0,
      soundSystemDetails: "",
      lightingSystemDetails: "",
      wifiAvailable: 0,
      projectorAvailable: 0,
      microphoneAvailable: 0,
      cleaningCost: 0,
      securityCost: 0,
      decorCost: 0,
      additionalServicesCost: 0,
      slots: [],
      images: [],
    );
  }
}

// Slot and HallImage classes remain unchanged
class Slot {
  String? slotFromTime;
  String? slotToTime;

  Slot({this.slotFromTime, this.slotToTime});

  Slot.fromJson(Map<String, dynamic> json) {
    slotFromTime = json['slot_from_time'];
    slotToTime = json['slot_to_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['slot_from_time'] = slotFromTime;
    data['slot_to_time'] = slotToTime;
    return data;
  }
}

class HallImage {
  String? url;

  HallImage({this.url});

  HallImage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}