class Profile {
  final int? id;
  final String? name;
  final String? bio;
  final String? profilePicPath;

  const Profile({this.id, this.name, this.bio, this.profilePicPath});

  Profile copyWith({
    int? id,
    String? name,
    String? bio,
    String? profilePicPath,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePicPath: profilePicPath ?? this.profilePicPath,
    );
  }
}
