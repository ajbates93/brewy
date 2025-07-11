import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _editProfile() async {
    final viewModel = context.read<ProfileViewModel?>();
    if (viewModel == null) return;
    final profile = viewModel.profile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF232326),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: _ProfileEditForm(
          initialName: profile?.name ?? '',
          initialBio: profile?.bio ?? '',
          onSave: (name, bio) async {
            await viewModel.saveProfile(name: name, bio: bio);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _editProfilePic() async {
    final viewModel = context.read<ProfileViewModel?>();
    if (viewModel == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      await viewModel.saveProfile(profilePicPath: picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel?>(
      builder: (context, viewModel, child) {
        if (viewModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Profile',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: (viewModel.isLoading) ? null : _editProfile,
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (viewModel.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading profile',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final profile = viewModel.profile;
              final name = (profile?.name != null && profile!.name!.isNotEmpty)
                  ? profile.name!
                  : 'No name set';
              final bio = (profile?.bio != null && profile!.bio!.isNotEmpty)
                  ? profile.bio!
                  : 'No bio set';

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white12,
                          backgroundImage: profile?.profilePicPath != null
                              ? FileImage(File(profile!.profilePicPath!))
                              : null,
                          child: profile?.profilePicPath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.white38,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: _editProfilePic,
                            tooltip: 'Change Profile Picture',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Name',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    bio,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bio',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProfileEditForm extends StatefulWidget {
  final String initialName;
  final String initialBio;
  final Future<void> Function(String name, String bio) onSave;

  const _ProfileEditForm({
    required this.initialName,
    required this.initialBio,
    required this.onSave,
  });

  @override
  State<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<_ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _bio;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter a name'
                : null,
            onChanged: (value) => setState(() => _name = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _bio,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Bio',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            onChanged: (value) => setState(() => _bio = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSubmitting = true);
                      await widget.onSave(_name.trim(), _bio.trim());
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
