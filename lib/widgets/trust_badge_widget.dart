import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/services/rating_service.dart';
import 'package:rentrig/utils/app_colors.dart';

class TrustBadgeWidget extends StatelessWidget {
  final String userId;
  final bool compact;
  final IRatingService ratingService;

  TrustBadgeWidget({
    super.key,
    required this.userId,
    this.compact = false,
    IRatingService? ratingService,
  }) : ratingService = ratingService ?? RatingService();

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<TrustMetrics>(
      stream: ratingService.streamTrustMetrics(userId),
      builder: (context, snapshot) {
        final metrics = snapshot.data ??
            TrustMetrics(
              averageRating: 5.0,
              totalReviews: 0,
              trustScore: 98,
              isVerified: true,
              trustBadgeTitle: 'Verified Rig Master',
            );

        if (compact) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: AppColors.accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${metrics.trustScore}% Trust',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          metrics.trustBadgeTitle,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accent,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trust Score: ${metrics.trustScore}% • ${metrics.averageRating.toStringAsFixed(1)} ★ (${metrics.totalReviews} reviews)',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.titaniumLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
