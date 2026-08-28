import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentrig/services/firestore_service.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/profile_info_widget.dart';
import 'package:rentrig/widgets/trust_badge_widget.dart';
import 'package:rentrig/utils/date_util.dart' as app_date_utils;
import '../widgets/custom_action_button.dart';

class ProfileScreen extends StatefulWidget {
  final IFirestoreService? firestoreService;

  const ProfileScreen({
    super.key,
    this.firestoreService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final IFirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = widget.firestoreService ?? FirestoreService();
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/log_in', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.7),
            radius: 1.3,
            colors: [
              AppColors.backgroundGradient,
              AppColors.background,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: currentUser != null
              ? _firestoreService.getUserProfileStream(currentUser.uid)
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            final userData = snapshot.data;
            final email = currentUser?.email ?? 'No email';
            final name = (userData?['name'] as String?) ?? currentUser?.displayName ?? email;
            final phone = userData?['phone'] as String?;
            final address = userData?['address'] as String?;
            final profileImageUrl = userData?['profileImageUrl'] as String?;
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

            return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.18),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.surface,
                          backgroundImage: profileImageUrl != null &&
                                  profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl == null ||
                                  profileImageUrl.isEmpty
                              ? Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                    letterSpacing: -1,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(context, 22),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Member ID: ${currentUser?.uid.substring(0, 8) ?? 'N/A'}...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (currentUser != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TrustBadgeWidget(userId: currentUser.uid),
                      ),
                    const SizedBox(height: 36),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtil.padding(context, 24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT DETAILS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ProfileInfoCard(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: email,
                          ),
                          const SizedBox(height: 14),
                          if (phone != null && phone.isNotEmpty) ...[
                            ProfileInfoCard(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              value: phone,
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (address != null && address.isNotEmpty) ...[
                            ProfileInfoCard(
                              icon: Icons.location_on_outlined,
                              title: 'Address',
                              value: address,
                            ),
                            const SizedBox(height: 14),
                          ],
                          ProfileInfoCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'Account Created',
                            value: currentUser?.metadata.creationTime != null
                                ? app_date_utils.DateUtils.formatShortDate(
                                    currentUser!.metadata.creationTime!,
                                  )
                                : 'Unknown',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtil.padding(context, 24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIONS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomActionButton(
                            label: 'Pending Requests',
                            icon: Icons.notifications_active_outlined,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/pending_requests',
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomActionButton(
                            label: 'Logout',
                            icon: Icons.logout_rounded,
                            onPressed: _logout,
                            backgroundColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
          },
        ),
      ),
    );
  }
}
