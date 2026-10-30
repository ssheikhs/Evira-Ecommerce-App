import 'package:flutter/foundation.dart';

@immutable
class ShippingAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
  });

  static const ShippingAddress empty = ShippingAddress(
    fullName: '',
    phone: '',
    address: '',
    city: '',
    postalCode: '',
  );

  /// `House 12, Road 5, Dhaka 1207`
  String get singleLine => '$address, $city $postalCode';

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullName: map['fullName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      postalCode: map['postalCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'city': city,
    'postalCode': postalCode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddress &&
          other.fullName == fullName &&
          other.phone == phone &&
          other.address == address &&
          other.city == city &&
          other.postalCode == postalCode;

  @override
  int get hashCode => Object.hash(fullName, phone, address, city, postalCode);
}
