import '../../domain/entities/profile.dart';
import '../dao/profile_dao.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDao _profileDao;

  ProfileRepositoryImpl(this._profileDao);

  @override
  Future<Profile?> getProfile() async {
    final profileModel = await _profileDao.getProfile();
    return profileModel;
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    print(
      'ProfileRepositoryImpl: Saving profile - ${profile.name}, ${profile.bio}, ${profile.id}',
    );
    final profileModel = ProfileModel.fromEntity(profile);
    print(
      'ProfileRepositoryImpl: ProfileModel created - ${profileModel.name}, ${profileModel.bio}, ${profileModel.id}',
    );
    final result = await _profileDao.upsertProfile(profileModel);
    print('ProfileRepositoryImpl: Upsert result - $result');
  }
}
