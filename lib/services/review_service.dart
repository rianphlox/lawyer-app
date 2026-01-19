import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../core/constants.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new review
  Future<void> addReview({
    required String lawyerId,
    required String clientId,
    required String clientName,
    required String clientImageUrl,
    required double rating,
    required String comment,
    List<String> tags = const [],
    String? gigId,
  }) async {
    try {
      final reviewId = _firestore
          .collection(AppConstants.reviewsCollection)
          .doc()
          .id;

      final review = Review(
        id: reviewId,
        lawyerId: lawyerId,
        clientId: clientId,
        clientName: clientName,
        clientImageUrl: clientImageUrl,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        tags: tags,
        gigId: gigId,
      );

      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .set(review.toJson());

      // Update lawyer's rating
      await _updateLawyerRating(lawyerId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get reviews for a lawyer
  Stream<List<Review>> getReviewsForLawyer(String lawyerId) {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromJson(doc.data()))
            .toList());
  }

  // Get paginated reviews for a lawyer
  Future<List<Review>> getPaginatedReviews({
    required String lawyerId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.reviewsCollection)
          .where('lawyerId', isEqualTo: lawyerId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated reviews: $e');
    }
  }

  // Get reviews by a client
  Future<List<Review>> getReviewsByClient(String clientId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get client reviews: $e');
    }
  }

  // Get review summary for a lawyer
  Future<ReviewSummary> getReviewSummary(String lawyerId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('lawyerId', isEqualTo: lawyerId)
          .get();

      if (snapshot.docs.isEmpty) {
        return const ReviewSummary(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {},
          recentReviews: [],
          commonTags: [],
        );
      }

      final reviews = snapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();

      // Calculate average rating
      final totalRating = reviews.fold(0.0, (accumulator, review) => accumulator + review.rating);
      final averageRating = totalRating / reviews.length;

      // Calculate rating distribution
      final ratingDistribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingDistribution[i] = reviews
            .where((review) => review.rating.round() == i)
            .length;
      }

      // Get recent reviews (last 5)
      final recentReviews = reviews
          .where((review) => review.isRecent)
          .take(5)
          .toList();

      // Get common tags
      final allTags = reviews.expand((review) => review.tags).toList();
      final tagFrequency = <String, int>{};
      for (final tag in allTags) {
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
      }
      final commonTags = tagFrequency.entries
          .where((entry) => entry.value >= 2)
          .map((entry) => entry.key)
          .take(5)
          .toList();

      return ReviewSummary(
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingDistribution: ratingDistribution,
        recentReviews: recentReviews,
        commonTags: commonTags,
      );
    } catch (e) {
      throw Exception('Failed to get review summary: $e');
    }
  }

  // Update a review
  Future<void> updateReview({
    required String reviewId,
    String? comment,
    double? rating,
    List<String>? tags,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (comment != null) updates['comment'] = comment;
      if (rating != null) updates['rating'] = rating;
      if (tags != null) updates['tags'] = tags;

      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .update(updates);

      // Update lawyer's rating if rating changed
      if (rating != null) {
        final reviewDoc = await _firestore
            .collection(AppConstants.reviewsCollection)
            .doc(reviewId)
            .get();

        if (reviewDoc.exists) {
          final review = Review.fromJson(reviewDoc.data()!);
          await _updateLawyerRating(review.lawyerId);
        }
      }
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final reviewDoc = await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .get();

      if (reviewDoc.exists) {
        final review = Review.fromJson(reviewDoc.data()!);

        await _firestore
            .collection(AppConstants.reviewsCollection)
            .doc(reviewId)
            .delete();

        // Update lawyer's rating
        await _updateLawyerRating(review.lawyerId);
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Mark review as helpful
  Future<void> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      final increment = isHelpful ? 1 : -1;
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .update({
        'isHelpful': isHelpful,
        'helpfulCount': FieldValue.increment(increment),
      });
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  // Check if client can review lawyer
  Future<bool> canClientReviewLawyer({
    required String clientId,
    required String lawyerId,
    String? gigId,
  }) async {
    try {
      // Check if client has already reviewed this lawyer
      Query query = _firestore
          .collection(AppConstants.reviewsCollection)
          .where('clientId', isEqualTo: clientId)
          .where('lawyerId', isEqualTo: lawyerId);

      if (gigId != null) {
        query = query.where('gigId', isEqualTo: gigId);
      }

      final existingReviews = await query.get();

      // If reviewing for a specific gig, only one review per gig is allowed
      if (gigId != null) {
        return existingReviews.docs.isEmpty;
      }

      // For general reviews, check if there's a completed transaction
      // This would require checking applications or bookings collection
      return existingReviews.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get review statistics for admin
  Future<Map<String, dynamic>> getReviewStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .get();

      final reviews = snapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();

      final totalReviews = reviews.length;
      final averageRating = reviews.isEmpty
          ? 0.0
          : reviews.fold(0.0, (accumulator, review) => accumulator + review.rating) / totalReviews;

      final recentReviews = reviews
          .where((review) => review.isRecent)
          .length;

      final verifiedReviews = reviews
          .where((review) => review.isVerified)
          .length;

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'recentReviews': recentReviews,
        'verifiedReviews': verifiedReviews,
        'verificationRate': totalReviews > 0 ? verifiedReviews / totalReviews : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get review statistics: $e');
    }
  }

  // Update lawyer's rating based on all reviews
  Future<void> _updateLawyerRating(String lawyerId) async {
    try {
      final reviewSummary = await getReviewSummary(lawyerId);

      await _firestore
          .collection(AppConstants.lawyersCollection)
          .doc(lawyerId)
          .update({
        'rating': reviewSummary.averageRating,
        'reviewCount': reviewSummary.totalReviews,
      });
    } catch (e) {
      // Don't throw here to avoid failing the main review operation
      debugPrint('Failed to update lawyer rating: $e');
    }
  }

  // Get featured reviews (high-rated, recent)
  Future<List<Review>> getFeaturedReviews({
    String? lawyerId,
    int limit = 5,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.reviewsCollection)
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .where('isVerified', isEqualTo: true)
          .orderBy('rating', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lawyerId != null) {
        query = query.where('lawyerId', isEqualTo: lawyerId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured reviews: $e');
    }
  }

  // Get reviews with specific tags
  Future<List<Review>> getReviewsByTags({
    required String lawyerId,
    required List<String> tags,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('lawyerId', isEqualTo: lawyerId)
          .where('tags', arrayContainsAny: tags)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews by tags: $e');
    }
  }
}