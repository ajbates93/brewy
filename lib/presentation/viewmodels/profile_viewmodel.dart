import 'package:flutter/foundation.dart';
import '../../domain/entities/profile.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileViewModel(this._repository);

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      _profile = await _repository.getProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveProfile({
    String? name,
    String? bio,
    String? profilePicPath,
  }) async {
    _setLoading(true);
    try {
      print(
        'ProfileViewModel: Saving profile - name: $name, bio: $bio, profilePicPath: $profilePicPath',
      );
      print(
        'ProfileViewModel: Current profile - ${_profile?.name}, ${_profile?.bio}, ${_profile?.id}',
      );

      final updatedProfile = Profile(
        id: _profile?.id,
        name: name ?? _profile?.name,
        bio: bio ?? _profile?.bio,
        profilePicPath: profilePicPath ?? _profile?.profilePicPath,
      );

      print(
        'ProfileViewModel: Updated profile - ${updatedProfile.name}, ${updatedProfile.bio}, ${updatedProfile.id}',
      );

      await _repository.saveProfile(updatedProfile);
      print('ProfileViewModel: Profile saved to repository');

      // Reload the profile to get the correct ID and ensure data consistency
      await loadProfile();
      print(
        'ProfileViewModel: Profile reloaded - ${_profile?.name}, ${_profile?.bio}, ${_profile?.id}',
      );
    } catch (e) {
      print('ProfileViewModel: Error saving profile - $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
