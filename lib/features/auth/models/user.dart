class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'Customer' or 'Provider'
  final String? profileImage;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
  });

  UserModel copyWith({String? profileImage}) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'] ?? '',
      role: map['role'],
      profileImage: map['profile_image'],
    );
  }
}
