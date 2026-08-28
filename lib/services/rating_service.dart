import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentrig/models/user_rating_model.dart';

class TrustMetrics {
  final double averageRating;
  final int totalReviews;
  final int trustScore;
  final bool isVerified;
  final String trustBadgeTitle;

  TrustMetrics({
    required this.averageRating,
    required this.totalReviews,
    required this.trustScore,
    required this.isVerified,
    required this.trustBadgeTitle,
  });
}

abstract interface class IRatingService {
  Future<void> submitRating(UserRating rating);
  Stream<List<UserRating>> getUserRatings(String userId);
  Stream<TrustMetrics> streamTrustMetrics(String userId);
}

class RatingService implements IRatingService {
  final FirebaseFirestore _db;

  RatingService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<void> submitRating(UserRating rating) async {
    try {
      await _db.collection('ratings').add(rating.toMap());
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  @override
  Stream<List<UserRating>> getUserRatings(String userId) {
    return _db
        .collection('ratings')
        .where('targetUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final ratings = snapshot.docs.map((doc) => UserRating.fromFirestore(doc)).toList();
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ratings;
    });
  }

  @override
  Stream<TrustMetrics> streamTrustMetrics(String userId) {
    return getUserRatings(userId).map((ratings) {
      if (ratings.isEmpty) {
        return TrustMetrics(
          averageRating: 5.0,
          totalReviews: 0,
          trustScore: 95,
          isVerified: true,
          trustBadgeTitle: 'Hardware Master',
        );
      }

      double sum = 0;
      for (var r in ratings) {
        sum += r.rating;
      }
      double avg = sum / ratings.length;
      int score = (avg / 5.0 * 100).round();

      String badge = 'Hardware Partner';
      if (score >= 95) {
        badge = 'Verified Rig Master';
      } else if (score >= 85) {
        badge = 'Trusted Renter';
      }

      return TrustMetrics(
        averageRating: avg,
        totalReviews: ratings.length,
        trustScore: score,
        isVerified: true,
        trustBadgeTitle: badge,
      );
    });
  }
}
