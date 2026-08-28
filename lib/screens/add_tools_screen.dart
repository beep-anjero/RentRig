import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/services/firestore_service.dart';
import 'package:rentrig/services/image_service.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/forms_util.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import 'package:rentrig/widgets/custom_dropdown_widget.dart';
import 'package:rentrig/widgets/text_field_widget.dart';

class AddToolScreen extends StatefulWidget {
  const AddToolScreen({super.key});

  @override
  State<AddToolScreen> createState() => _AddToolScreenState();
}

class _AddToolScreenState extends State<AddToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ImageService _imageService = ImageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedCategory = 'Cameras & Optics';
  String _selectedCondition = 'Good';
  bool _isLoading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  final List<String> _categories = [
    'Cameras & Optics',
    'Audio & Sound',
    'VR & AR',
    'Drones & Robotics',
    'Laptops & Workstations',
    'Dev Kits & IoT',
    'Servers & Networking',
    '3D Printers',
    'Power & Batteries',
    'Tools & Machinery',
    'Other Tech',
  ];

  final List<String> _conditions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imageService.pickImageFromGallery();
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addTool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      if (_selectedImage != null) {
        _uploadedImageUrl = await _imageService.uploadToolImage(
          _selectedImage!,
          currentUser.uid,
        );
      }

      final newTool = Tool(
        ownerId: currentUser.uid,
        ownerEmail: currentUser.email ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        condition: _selectedCondition,
        imageUrl: _uploadedImageUrl,
        isAvailable: true,
      );

      await _firestoreService.createTool(newTool);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tool added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppDecorations.darkAppBar(title: 'Add New Tool'),
      body: AppDecorations.darkBody(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtil.padding(context, 24)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldWidget(
                  controller: _nameController,
                  labelText: 'Tool Name',
                  hintText: 'e.g., Cordless Drill',
                  validator: (value) =>
                      FormValidators.required(value, fieldName: 'tool name'),
                ),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  value: _selectedCategory,
                  labelText: 'Category',
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFieldWidget(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Describe your tool...',
                  maxLines: 4,
                  validator: (value) => FormValidators.minLength(
                    value,
                    10,
                    fieldName: 'Description',
                  ),
                ),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  value: _selectedCondition,
                  labelText: 'Condition',
                  items: _conditions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppDecorations.glassCard(radius: 12),
                  child: InkWell(
                    onTap: _isLoading ? null : _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pick Image from Gallery',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedImage != null
                                      ? 'Image selected'
                                      : 'Tap to select an image',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedImage != null)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: AppDecorations.glassCard(radius: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.glassCard(radius: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your tool will be visible to all RentRig users',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomActionButton(
                  label: _isLoading ? 'Adding...' : 'Add Tool',
                  icon: Icons.add,
                  onPressed: _isLoading ? () {} : _addTool,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
