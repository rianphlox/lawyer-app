import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _barAssociationController = TextEditingController();
  final TextEditingController _yearsExperienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  // Document uploads
  File? _licenseDocument;
  File? _certificationDocument;
  File? _profileImage;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify Your Profile',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please provide the required documents and information to verify your lawyer profile',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Profile Image
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: AppTheme.borderLight,
                                width: 2,
                              ),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 32,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // License Number
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: CustomTextField(
                        controller: _licenseNumberController,
                        label: 'License Number',
                        prefixIcon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your license number';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bar Association
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 250),
                      child: CustomTextField(
                        controller: _barAssociationController,
                        label: 'Bar Association',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your bar association';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Years of Experience
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: CustomTextField(
                        controller: _yearsExperienceController,
                        label: 'Years of Experience',
                        prefixIcon: Icons.work_outline_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your years of experience';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Specialization
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 350),
                      child: CustomTextField(
                        controller: _specializationController,
                        label: 'Primary Specialization',
                        prefixIcon: Icons.gavel_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your primary specialization';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // About
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: CustomTextField(
                        controller: _aboutController,
                        label: 'About Yourself',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please tell us about yourself';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Document Uploads
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 450),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Documents',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // License Document
                          _buildDocumentUpload(
                            title: 'License Certificate',
                            description: 'Upload your legal practice license',
                            file: _licenseDocument,
                            onTap: () => _pickDocument(true),
                            icon: Icons.description_outlined,
                          ),

                          const SizedBox(height: 16),

                          // Certification Document
                          _buildDocumentUpload(
                            title: 'Professional Certification',
                            description: 'Upload any relevant certifications',
                            file: _certificationDocument,
                            onTap: () => _pickDocument(false),
                            icon: Icons.workspace_premium_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        child: LoadingButton(
                          onPressed: _handleSubmit,
                          isLoading: _isSubmitting,
                          text: 'Submit for Verification',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Skip for now button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 550),
                      child: SizedBox(
                        width: double.infinity,
                        child: LoadingButton(
                          onPressed: () => context.go(AppRoutes.home),
                          isLoading: false,
                          text: 'Skip for Now',
                          outlined: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: Text(
                        'Note: Unverified profiles have limited access to premium features.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String description,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? AppTheme.primaryColor : AppTheme.borderLight,
            width: file != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (file != null ? AppTheme.primaryColor : AppTheme.textSecondary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                file != null ? Icons.check_circle_outline : icon,
                color: file != null ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? 'Document uploaded' : description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: file != null ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.edit_outlined : Icons.upload_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument(bool isLicense) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          if (isLicense) {
            _licenseDocument = File(file.path);
          } else {
            _certificationDocument = File(file.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick document: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_licenseDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your license certificate'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // In a real app, you would upload the documents to Firebase Storage
      // and update the user's profile with the verification information

      await authProvider.updateProfile(
        metadata: {
          'licenseNumber': _licenseNumberController.text.trim(),
          'barAssociation': _barAssociationController.text.trim(),
          'yearsExperience': int.parse(_yearsExperienceController.text.trim()),
          'specialization': _specializationController.text.trim(),
          'about': _aboutController.text.trim(),
          'verificationStatus': 'pending',
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit verification: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _barAssociationController.dispose();
    _yearsExperienceController.dispose();
    _specializationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}