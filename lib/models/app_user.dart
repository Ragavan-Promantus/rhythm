class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.username = '',
    this.mobile = '',
    this.profileImage = '',
    this.role = 'USER',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final String username;
  final String mobile;
  final String profileImage;
  final String role;
  final bool isActive;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final username = '${json['username'] ?? json['name'] ?? ''}';
    final fullName =
        '${json['name'] ?? json['fullName'] ?? json['username'] ?? 'Listener'}';

    return AppUser(
      id: '${json['id'] ?? json['_id'] ?? json['userId'] ?? ''}',
      name: fullName,
      email: '${json['email'] ?? ''}',
      username: username,
      mobile: '${json['mobile'] ?? ''}',
      profileImage: '${json['profile_image'] ?? json['profileImage'] ?? ''}',
      role: '${json['role'] ?? 'USER'}',
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'mobile': mobile,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive,
    };
  }
}
