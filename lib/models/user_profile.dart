class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? 'No Email',
      // Using a reliable robohash fallback for public avatar imaging vectors
      avatarUrl: 'https://robohash.org/${json['id'] ?? 1}.png?size=150x150',
    );
  }
}