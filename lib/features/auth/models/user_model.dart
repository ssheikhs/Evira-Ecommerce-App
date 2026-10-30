import 'package:flutter/foundation.dart';

/// The signed-in DummyJSON user.
@immutable
class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;
  final String phone;
  final String address;
  final String city;
  final String postalCode;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  String get initials {
    final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Reads both the flat shape we save locally and the nested `address`
  /// object that DummyJSON returns from `/auth/me`.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final address = map['address'] is Map
        ? Map<String, dynamic>.from(map['address'] as Map)
        : const <String, dynamic>{};

    return UserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address:
          address['address']?.toString() ?? map['street']?.toString() ?? '',
      city: address['city']?.toString() ?? map['city']?.toString() ?? '',
      postalCode:
          address['postalCode']?.toString() ??
          map['postalCode']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'image': image,
    'phone': phone,
    'street': address,
    'city': city,
    'postalCode': postalCode,
  };

  /// Keeps address details we already know when a response leaves them out
  /// (`/auth/login` returns no address, `/auth/me` does).
  UserModel mergeMissing(UserModel? other) {
    if (other == null || other.id != id) return this;
    return UserModel(
      id: id,
      username: username,
      email: email.isNotEmpty ? email : other.email,
      firstName: firstName,
      lastName: lastName,
      image: image.isNotEmpty ? image : other.image,
      phone: phone.isNotEmpty ? phone : other.phone,
      address: address.isNotEmpty ? address : other.address,
      city: city.isNotEmpty ? city : other.city,
      postalCode: postalCode.isNotEmpty ? postalCode : other.postalCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && other.id == id && other.username == username;

  @override
  int get hashCode => Object.hash(id, username);
}
