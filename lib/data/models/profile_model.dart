import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({super.id, super.name, super.bio, super.profilePicPath});

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      bio: map['bio'] as String?,
      profilePicPath: map['profile_pic_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profile_pic_path': profilePicPath,
    };
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      name: profile.name,
      bio: profile.bio,
      profilePicPath: profile.profilePicPath,
    );
  }
}
