import 'package:sqflite/sqflite.dart';
import '../models/profile_model.dart';

class ProfileDao {
  final Database _database;

  ProfileDao(this._database);

  Future<ProfileModel?> getProfile() async {
    print('ProfileDao: Getting profile from database');
    final List<Map<String, dynamic>> maps = await _database.query(
      'profiles',
      orderBy: 'id DESC',
      limit: 1,
    );
    print('ProfileDao: Found ${maps.length} profiles in database');
    if (maps.isNotEmpty) {
      print('ProfileDao: Retrieved profile - ${maps.first}');
    }
    if (maps.isEmpty) return null;
    final profile = ProfileModel.fromMap(maps.first);
    print(
      'ProfileDao: Returning profile - ${profile.name}, ${profile.bio}, ${profile.id}',
    );
    return profile;
  }

  Future<int> insertProfile(ProfileModel profile) async {
    print('ProfileDao: Inserting profile into database - ${profile.toMap()}');
    final result = await _database.insert('profiles', profile.toMap());
    print('ProfileDao: Insert completed with ID - $result');
    return result;
  }

  Future<int> updateProfile(ProfileModel profile) async {
    if (profile.id == null) {
      throw Exception('Profile ID is required for update');
    }
    print('ProfileDao: Updating profile in database - ${profile.toMap()}');
    final result = await _database.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    print('ProfileDao: Update completed - $result rows affected');
    return result;
  }

  Future<int> upsertProfile(ProfileModel profile) async {
    print(
      'ProfileDao: Upserting profile - ${profile.name}, ${profile.bio}, ${profile.id}',
    );
    if (profile.id == null) {
      print('ProfileDao: Inserting new profile');
      final result = await insertProfile(profile);
      print('ProfileDao: Insert result - $result');
      return result;
    } else {
      print('ProfileDao: Updating existing profile');
      final result = await updateProfile(profile);
      print('ProfileDao: Update result - $result');
      return result;
    }
  }
}
