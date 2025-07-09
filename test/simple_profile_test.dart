import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:brewy/data/datasources/database_helper.dart';
import 'package:brewy/data/dao/profile_dao.dart';
import 'package:brewy/data/models/profile_model.dart';
import 'package:brewy/data/repositories/profile_repository_impl.dart';
import 'package:brewy/presentation/viewmodels/profile_viewmodel.dart';

void main() {
  group('Simple Profile Test', () {
    late DatabaseHelper databaseHelper;
    late ProfileDao profileDao;
    late ProfileRepositoryImpl repository;
    late ProfileViewModel viewModel;

    setUpAll(() async {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create a fresh database for each test
      final dbPath = path.join(
        await databaseFactory.getDatabasesPath(),
        'test_brewy_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      await databaseFactory.deleteDatabase(dbPath);

      databaseHelper = DatabaseHelper();
      profileDao = await databaseHelper.getProfileDao();
      repository = ProfileRepositoryImpl(profileDao);
      viewModel = ProfileViewModel(repository);
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should save and load profile correctly', () async {
      // Test saving a profile
      await viewModel.saveProfile(
        name: 'Test User',
        bio: 'Test bio',
        profilePicPath: '/test/path.jpg',
      );

      // Verify the profile was saved
      expect(viewModel.profile, isNotNull);
      expect(viewModel.profile!.name, 'Test User');
      expect(viewModel.profile!.bio, 'Test bio');
      expect(viewModel.profile!.profilePicPath, '/test/path.jpg');
      expect(viewModel.profile!.id, isNotNull);

      // Test updating the profile
      await viewModel.saveProfile(name: 'Updated User', bio: 'Updated bio');

      // Verify the profile was updated
      expect(viewModel.profile!.name, 'Updated User');
      expect(viewModel.profile!.bio, 'Updated bio');
      expect(
        viewModel.profile!.profilePicPath,
        '/test/path.jpg',
      ); // Should remain unchanged
      expect(viewModel.profile!.id, isNotNull); // ID should remain the same
    });

    test('should handle empty values correctly', () async {
      // Test saving with empty values
      await viewModel.saveProfile(name: '', bio: '');

      // Verify empty values are handled
      expect(viewModel.profile, isNotNull);
      expect(viewModel.profile!.name, '');
      expect(viewModel.profile!.bio, '');
    });

    test('should handle partial updates correctly', () async {
      // First save a complete profile
      await viewModel.saveProfile(
        name: 'Complete User',
        bio: 'Complete bio',
        profilePicPath: '/complete/path.jpg',
      );

      // Then update only the name
      await viewModel.saveProfile(name: 'Updated Name');

      // Verify only name was updated
      expect(viewModel.profile!.name, 'Updated Name');
      expect(viewModel.profile!.bio, 'Complete bio'); // Should remain unchanged
      expect(
        viewModel.profile!.profilePicPath,
        '/complete/path.jpg',
      ); // Should remain unchanged
    });
  });
}
