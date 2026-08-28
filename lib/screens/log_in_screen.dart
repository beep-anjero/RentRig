import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/forms_util.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import 'package:rentrig/widgets/tech_monogram_logo.dart';
import 'package:rentrig/widgets/text_field_widget.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const String _googleSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24">
  <path fill="currentColor" d="M21.35 11.1h-9.17v2.73h6.51c-.33 1.56-1.56 2.95-3.24 3.5v2.9h5.21c3.06-2.82 4.82-6.99 4.82-11.89c0-.62-.06-1.21-.13-1.74Z"/>
  <path fill="currentColor" d="M12.18 21.8c3.27 0 6.01-1.09 8.01-2.97l-5.21-2.9c-1.44.97-3.29 1.54-5.32 1.54c-4.1 0-7.58-2.77-8.81-6.5H.53v3.01c2.04 4.07 6.27 6.82 11.65 6.82Z"/>
  <path fill="currentColor" d="M3.37 10.97c-.31-.97-.49-2-.49-3.07s.18-2.1.49-3.07V1.82H.53c-1.05 2.1-1.65 4.47-1.65 6.98c0 2.51.6 4.88 1.65 6.98l2.84-2.81Z"/>
  <path fill="currentColor" d="M12.18 1.63c2.2 0 4.18.76 5.73 2.24l4.28-4.23C19.61-2.5 16.15-4.1 12.18-4.1C6.8-4.1 2.57-1.35.53 2.72l3.37 3.36c1.23-3.73 4.71-6.5 8.81-6.5Z"/>
</svg>
''';

  static const String _appleSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24">
  <path fill="currentColor" d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.58 2.95-1.39Z"/>
</svg>
''';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }

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

  Widget _buildSocialButton({
    required String svgString,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: SvgPicture.string(
              svgString,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.6),
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
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.06),
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
                        size: 40,
                        showText: true,
                        isVertical: false,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enterprise Technology & Hardware Sharing',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.titaniumLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: ResponsiveUtil.formWidth(context),
                        padding: EdgeInsets.all(
                          ResponsiveUtil.padding(context, 28),
                        ),
                        decoration: AppDecorations.glassCard(radius: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFieldWidget(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                validator: FormValidators.email,
                              ),
                              const SizedBox(height: 16),
                              TextFieldWidget(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                validator: FormValidators.password,
                                obscureText: true,
                                showPasswordToggle: true,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password reset is not configured',
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppColors.accent.withOpacity(0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
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
                                        label: 'Login',
                                        icon: Icons.login,
                                        onPressed: _login,
                                      ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.06),
                                      height: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'OR CONNECT WITH',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.06),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    svgString: _googleSvg,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Google Sign-In is currently unavailable',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(
                                    svgString: _appleSvg,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Apple Sign-In is currently unavailable',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
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
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/sign_up');
                            },
                            child: const Text(
                              'Sign Up',
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
