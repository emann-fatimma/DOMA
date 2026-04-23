// lib/models/user_model.dart

class Address {
  final String label, street, city, state, zipCode, country;
  final bool isDefault;

  Address({
    required this.label,
    required this.street,
    required this.city,
    this.state = '',
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode, // Matches Payload field name
    'country': country,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    label: json['label'] ?? 'Address',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    zipCode: json['zipCode'] ?? '',
    country: json['country'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );
}

class UserModel {
  final String id, email, name, phone, status;
  final List<Address> addresses;
  final dynamic avatar;
  final String? googleId; // ✅ Add this

  UserModel({
    required this.id, required this.email, required this.name,
    required this.phone, required this.status, required this.addresses,
    this.avatar,
    this.googleId, // ✅ Add this
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    final userData = json['customer'] ?? json['user'] ?? json;

    var addrData = userData['addresses'];
    List<Address> addressList = [];

    if (addrData != null && addrData is List) {
      addressList = addrData.map((a) => Address.fromJson(a)).toList();
    }

    return UserModel(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      name: userData['Name'] ?? '',
      phone: userData['phone'] ?? '',
      status: userData['status'] ?? '',
      avatar: userData['avatar'], // ✅ Fixed: was json['avatar'], should be userData['avatar']
      addresses: addressList,
      googleId: userData['googleId'], // ✅ Add this
    );
  }
}