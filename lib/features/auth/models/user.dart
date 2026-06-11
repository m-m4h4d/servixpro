class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role; // 'Customer' or 'Provider'
  final String? profileImage;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      role: map['role'],
      profileImage: map['profileImage'],
    );
  }
}
