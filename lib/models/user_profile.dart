class UserProfile {
  final int id;
  final String username, email, fullName, image;
  UserProfile({required this.id, required this.username,
    required this.email, required this.fullName, required this.image});

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        email: j['email'] ?? '',
        fullName: j['fullName'] ?? '${j['firstName'] ?? ''}'
            ' ${j['lastName'] ?? ''}'.trim(),
        image: j['image'] ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'email': email,
        'fullName': fullName, 'image': image};
}
