class UserProfile {
  const UserProfile({
    required this.username,
    required this.email,
    required this.phone,
    required this.levelCode,
    required this.levelLabel,
  });

  final String username;
  final String email;
  final String phone;
  final String levelCode;
  final String levelLabel;

  static const empty = UserProfile(
    username: "",
    email: "",
    phone: "",
    levelCode: "",
    levelLabel: "",
  );

  UserProfile copyWith({
    String? username,
    String? email,
    String? phone,
    String? levelCode,
    String? levelLabel,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      levelCode: levelCode ?? this.levelCode,
      levelLabel: levelLabel ?? this.levelLabel,
    );
  }
}
