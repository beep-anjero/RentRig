import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/services/firestore_service.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/widgets/tech_monogram_logo.dart';
import 'package:rentrig/widgets/trust_badge_widget.dart';

class DrawerWidget extends StatelessWidget {
  final VoidCallback onLogout;
  final IFirestoreService firestoreService;

  DrawerWidget({
    super.key,
    required this.onLogout,
    IFirestoreService? firestoreService,
  }) : firestoreService = firestoreService ?? FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.titanium,
                  width: 0.5,
                ),
              ),
            ),
            child: StreamBuilder<Map<String, dynamic>?>(
              stream: currentUser != null
                  ? firestoreService.getUserProfileStream(currentUser.uid)
                  : null,
              builder: (context, snapshot) {
                final userData = snapshot.data;
                final name = (userData?['name'] as String?) ?? currentUser?.displayName ?? currentUser?.email ?? 'Member';
                final profileImageUrl = userData?['profileImageUrl'] as String?;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TechMonogramLogo(
                      size: 28,
                      showText: true,
                      isVertical: false,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent.withOpacity(0.2),
                          backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl == null || profileImageUrl.isEmpty
                              ? Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (currentUser?.email != null)
                                Text(
                                  currentUser!.email!,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.white.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (currentUser != null)
                      TrustBadgeWidget(
                        userId: currentUser.uid,
                        compact: true,
                      ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded, color: AppColors.accent),
            title: Text(
              'Equipment Marketplace',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: AppColors.white),
            title: Text(
              'My tools',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my_tools');
            },
          ),
          ListTile(
            leading: const Icon(Icons.handshake_outlined, color: AppColors.white),
            title: Text(
              'Active Hardware Rentals',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/borrowed_tools');
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions_rounded, color: AppColors.white),
            title: Text(
              'Pending Rental Requests',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pending_requests');
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined, color: AppColors.white),
            title: Text(
              'Member Profile & Trust',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          Divider(color: AppColors.titanium.withOpacity(0.3)),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text(
              'Logout',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

