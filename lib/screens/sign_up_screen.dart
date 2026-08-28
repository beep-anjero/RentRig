import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/forms_util.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import 'package:rentrig/widgets/tech_monogram_logo.dart';
import 'package:rentrig/widgets/text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final currentUser = userCredential.user;
      if (currentUser != null) {
        final fullName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

        await currentUser.updateDisplayName(fullName);

        await _firestore.collection('users').doc(currentUser.uid).set({
          'name': fullName,
          'email': currentUser.email,
          'createdAt': FieldValue.serverTimestamp(),
          'phone': '',
          'address': '',
          'profileImageUrl': '',
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'An error occurred';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pushNamed(context, '/log_in'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.6),
            radius: 1.4,
            colors: [
              AppColors.backgroundGradient,
              AppColors.background,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.05),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtil.padding(context, 20),
                    vertical: ResponsiveUtil.padding(context, 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TechMonogramLogo(
                        size: 36,
                        showText: false,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create RENTRIG Profile',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join the enterprise technology and hardware sharing network',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.titaniumLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: ResponsiveUtil.formWidth(context),
                        padding: EdgeInsets.all(
                          ResponsiveUtil.padding(context, 28),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Register Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFieldWidget(
                                      controller: _firstNameController,
                                      labelText: 'First Name',
                                      hintText: 'John',
                                      validator: (value) =>
                                          FormValidators.required(
                                        value,
                                        fieldName: 'First Name',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFieldWidget(
                                      controller: _lastNameController,
                                      labelText: 'Last Name',
                                      hintText: 'Doe',
                                      validator: (value) =>
                                          FormValidators.required(
                                        value,
                                        fieldName: 'Last Name',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              TextFieldWidget(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'Enter new email',
                                keyboardType: TextInputType.emailAddress,
                                validator: FormValidators.email,
                              ),
                              const SizedBox(height: 18),
                              TextFieldWidget(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter new password',
                                validator: FormValidators.password,
                                obscureText: true,
                                showPasswordToggle: true,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: _isLoading
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: CircularProgressIndicator(
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      )
                                    : CustomActionButton(
                                        label: 'Sign Up',
                                        icon: Icons.person_add,
                                        onPressed: _signUp,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/log_in');
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
