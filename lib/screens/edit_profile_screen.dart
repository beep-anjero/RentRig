import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import '../services/image_service.dart';
import '../widgets/text_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String? _profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _phoneController.text = data?['phone'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _profileImageUrl = data?['profileImageUrl'];
          _isLoadingProfile = false;
        });
      } else {
        _nameController.text = currentUser.displayName ?? '';
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imageService.pickImageFromGallery();
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      String? imageUrl = _profileImageUrl;

      if (_selectedImage != null) {
        imageUrl = await _imageService.uploadToolImage(
          _selectedImage!,
          currentUser.uid,
        );

        if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
          try {
            await _imageService.deleteImage(_profileImageUrl!);
          } catch (e) {
            debugPrint('Failed to delete old image: $e');
          }
        }
      }

      await _firestore.collection('users').doc(currentUser.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'profileImageUrl': imageUrl,
        'email': currentUser.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await currentUser.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final email = currentUser?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppDecorations.darkAppBar(title: 'Edit Profile'),
      body: AppDecorations.darkBody(
        child: _isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentSecondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.surface,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (_profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty)
                                        ? NetworkImage(_profileImageUrl!)
                                        : null,
                                child: (_selectedImage == null &&
                                        (_profileImageUrl == null ||
                                            _profileImageUrl!.isEmpty))
                                    ? Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accent,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accentSecondary,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to change photo',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFieldWidget(
                        controller: _nameController,
                        labelText: 'Full Name',
                        hintText: 'Enter your name',
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _addressController,
                        labelText: 'Address',
                        hintText: 'Enter your address',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: TextEditingController(text: email),
                        labelText: 'Email',
                        hintText: email,
                        enabled: false,
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                            )
                          : CustomActionButton(
                              label: 'Save Changes',
                              icon: Icons.save,
                              onPressed: _saveProfile,
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
