// lib/models/user_model.dart
class UserModel {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final bool hasHelperProfile;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.hasHelperProfile = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    role: json['role'],
    hasHelperProfile: json['has_helper_profile'] ?? false,
  );
}
