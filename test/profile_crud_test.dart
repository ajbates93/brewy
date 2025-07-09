import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:brewy/data/datasources/database_helper.dart';
import 'package:brewy/data/dao/profile_dao.dart';
import 'package:brewy/data/models/profile_model.dart';
import 'package:brewy/data/repositories/profile_repository_impl.dart';
import 'package:brewy/presentation/viewmodels/profile_viewmodel.dart';

void main() {
  group('Profile CRUD Operations', () {
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
      // Create in-memory database for testing
      final dbPath = path.join(
        await databaseFactory.getDatabasesPath(),
        'test_brewy.db',
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

    group('ProfileDao Tests', () {
      test('should create profile table', () async {
        final db = await databaseHelper.database;
        final tables = await db.query(
          'sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'profiles'],
        );
        expect(tables.length, 1);
        expect(tables.first['name'], 'profiles');
      });

      test('should insert new profile', () async {
        final profile = ProfileModel(
          name: 'Test User',
          bio: 'Test bio',
          profilePicPath: '/test/path.jpg',
        );

        final id = await profileDao.insertProfile(profile);
        expect(id, isNotNull);
        expect(id, greaterThan(0));
      });

      test('should get profile by id', () async {
        final profile = ProfileModel(
          name: 'Test User',
          bio: 'Test bio',
          profilePicPath: '/test/path.jpg',
        );

        final id = await profileDao.insertProfile(profile);
        final retrieved = await profileDao.getProfile();

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test User');
        expect(retrieved.bio, 'Test bio');
        expect(retrieved.profilePicPath, '/test/path.jpg');
      });

      test('should update existing profile', () async {
        // Insert initial profile
        final profile = ProfileModel(name: 'Test User', bio: 'Test bio');
        final id = await profileDao.insertProfile(profile);

        // Update profile
        final updatedProfile = ProfileModel(
          id: id,
          name: 'Updated User',
          bio: 'Updated bio',
          profilePicPath: '/new/path.jpg',
        );
        final updateResult = await profileDao.updateProfile(updatedProfile);
        expect(updateResult, 1);

        // Verify update
        final retrieved = await profileDao.getProfile();
        expect(retrieved!.name, 'Updated User');
        expect(retrieved.bio, 'Updated bio');
        expect(retrieved.profilePicPath, '/new/path.jpg');
      });

      test(
        'should upsert profile (insert if not exists, update if exists)',
        () async {
          // First upsert - should insert
          final profile1 = ProfileModel(name: 'Test User', bio: 'Test bio');
          final id1 = await profileDao.upsertProfile(profile1);
          expect(id1, greaterThan(0));

          // Second upsert - should update
          final profile2 = ProfileModel(
            id: id1,
            name: 'Updated User',
            bio: 'Updated bio',
          );
          final id2 = await profileDao.upsertProfile(profile2);
          expect(id2, 1); // Update returns number of affected rows

          // Verify final state
          final retrieved = await profileDao.getProfile();
          expect(retrieved!.name, 'Updated User');
          expect(retrieved.bio, 'Updated bio');
        },
      );

      test('should return null when no profile exists', () async {
        final profile = await profileDao.getProfile();
        expect(profile, isNull);
      });
    });

    group('ProfileRepository Tests', () {
      test('should save and retrieve profile', () async {
        final profile = ProfileModel(
          name: 'Test User',
          bio: 'Test bio',
          profilePicPath: '/test/path.jpg',
        );

        await repository.saveProfile(profile);
        final retrieved = await repository.getProfile();

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test User');
        expect(retrieved.bio, 'Test bio');
        expect(retrieved.profilePicPath, '/test/path.jpg');
      });

      test('should update existing profile', () async {
        // Save initial profile
        final initialProfile = ProfileModel(
          name: 'Initial User',
          bio: 'Initial bio',
        );
        await repository.saveProfile(initialProfile);

        // Update profile
        final updatedProfile = ProfileModel(
          name: 'Updated User',
          bio: 'Updated bio',
          profilePicPath: '/new/path.jpg',
        );
        await repository.saveProfile(updatedProfile);

        // Verify update
        final retrieved = await repository.getProfile();
        expect(retrieved!.name, 'Updated User');
        expect(retrieved.bio, 'Updated bio');
        expect(retrieved.profilePicPath, '/new/path.jpg');
      });
    });

    group('ProfileViewModel Tests', () {
      test('should load profile successfully', () async {
        // Setup: save a profile first
        final profile = ProfileModel(name: 'Test User', bio: 'Test bio');
        await repository.saveProfile(profile);

        // Test loading
        await viewModel.loadProfile();

        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        expect(viewModel.profile, isNotNull);
        expect(viewModel.profile!.name, 'Test User');
        expect(viewModel.profile!.bio, 'Test bio');
      });

      test('should handle loading when no profile exists', () async {
        await viewModel.loadProfile();

        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        expect(viewModel.profile, isNull);
      });

      test('should save profile successfully', () async {
        await viewModel.saveProfile(
          name: 'New User',
          bio: 'New bio',
          profilePicPath: '/new/path.jpg',
        );

        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        expect(viewModel.profile, isNotNull);
        expect(viewModel.profile!.name, 'New User');
        expect(viewModel.profile!.bio, 'New bio');
        expect(viewModel.profile!.profilePicPath, '/new/path.jpg');

        // Verify it's actually saved to database
        final savedProfile = await repository.getProfile();
        expect(savedProfile!.name, 'New User');
        expect(savedProfile.bio, 'New bio');
        expect(savedProfile.profilePicPath, '/new/path.jpg');
      });

      test('should update existing profile', () async {
        // Setup: save initial profile
        await viewModel.saveProfile(name: 'Initial User', bio: 'Initial bio');

        // Update profile
        await viewModel.saveProfile(
          name: 'Updated User',
          bio: 'Updated bio',
          profilePicPath: '/updated/path.jpg',
        );

        expect(viewModel.profile!.name, 'Updated User');
        expect(viewModel.profile!.bio, 'Updated bio');
        expect(viewModel.profile!.profilePicPath, '/updated/path.jpg');

        // Verify it's actually saved to database
        final savedProfile = await repository.getProfile();
        expect(savedProfile!.name, 'Updated User');
        expect(savedProfile.bio, 'Updated bio');
        expect(savedProfile.profilePicPath, '/updated/path.jpg');
      });

      test('should handle partial updates', () async {
        // Setup: save complete profile
        await viewModel.saveProfile(
          name: 'Complete User',
          bio: 'Complete bio',
          profilePicPath: '/complete/path.jpg',
        );

        // Update only name
        await viewModel.saveProfile(name: 'Updated Name');

        expect(viewModel.profile!.name, 'Updated Name');
        expect(
          viewModel.profile!.bio,
          'Complete bio',
        ); // Should remain unchanged
        expect(
          viewModel.profile!.profilePicPath,
          '/complete/path.jpg',
        ); // Should remain unchanged
      });

      test('should handle database errors gracefully', () async {
        // Close database to simulate error
        await databaseHelper.close();

        await viewModel.saveProfile(name: 'Test User');

        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNotNull);
        expect(viewModel.error!.contains('Exception'), true);
      });
    });
  });
}
