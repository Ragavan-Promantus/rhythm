class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: '${json['id'] ?? json['_id'] ?? json['userId'] ?? ''}',
      name:
          '${json['name'] ?? json['fullName'] ?? json['username'] ?? 'Listener'}',
      email: '${json['email'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
