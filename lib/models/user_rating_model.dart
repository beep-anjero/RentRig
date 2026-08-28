import 'package:cloud_firestore/cloud_firestore.dart';

class UserRating {
  final String? id;
  final String targetUserId;
  final String reviewerId;
  final String reviewerEmail;
  final String rentalId;
  final double rating; // 1.0 - 5.0
  final String reviewText;
  final DateTime createdAt;

  UserRating({
    this.id,
    required this.targetUserId,
    required this.reviewerId,
    required this.reviewerEmail,
    required this.rentalId,
    required this.rating,
    required this.reviewText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'targetUserId': targetUserId,
      'reviewerId': reviewerId,
      'reviewerEmail': reviewerEmail,
      'rentalId': rentalId,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRating(
      id: doc.id,
      targetUserId: data['targetUserId'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewerEmail: data['reviewerEmail'] ?? '',
      rentalId: data['rentalId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: data['reviewText'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
