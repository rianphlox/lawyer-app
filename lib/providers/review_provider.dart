import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // State
  final List<Review> _reviews = [];
  ReviewSummary? _reviewSummary;
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreReviews = true;

  // Getters
  List<Review> get reviews => _reviews;
  ReviewSummary? get reviewSummary => _reviewSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreReviews => _hasMoreReviews;

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
      _setLoading(true);
      _clearError();

      await _reviewService.addReview(
        lawyerId: lawyerId,
        clientId: clientId,
        clientName: clientName,
        clientImageUrl: clientImageUrl,
        rating: rating,
        comment: comment,
        tags: tags,
        gigId: gigId,
      );

      // Refresh reviews and summary
      await loadReviews(lawyerId, refresh: true);
      await loadReviewSummary(lawyerId);

    } catch (e) {
      _setError('Failed to add review: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load reviews for a lawyer
  Future<void> loadReviews(String lawyerId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _reviews.clear();
        _lastDocument = null;
        _hasMoreReviews = true;
      }

      if (!_hasMoreReviews) return;

      _setLoading(true);
      _clearError();

      final newReviews = await _reviewService.getPaginatedReviews(
        lawyerId: lawyerId,
        lastDocument: _lastDocument,
        limit: 10,
      );

      if (newReviews.isEmpty) {
        _hasMoreReviews = false;
      } else {
        _reviews.addAll(newReviews);
        // Note: In a real implementation, you'd get the DocumentSnapshot
        // from the Firestore query to use as lastDocument
        _hasMoreReviews = newReviews.length == 10;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load reviews: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load review summary
  Future<void> loadReviewSummary(String lawyerId) async {
    try {
      _clearError();

      _reviewSummary = await _reviewService.getReviewSummary(lawyerId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load review summary: $e');
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
      _setLoading(true);
      _clearError();

      await _reviewService.updateReview(
        reviewId: reviewId,
        comment: comment,
        rating: rating,
        tags: tags,
      );

      // Find and update the review in local list
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(
          comment: comment,
          rating: rating,
          tags: tags,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update review: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String lawyerId) async {
    try {
      _setLoading(true);
      _clearError();

      await _reviewService.deleteReview(reviewId);

      // Remove from local list
      _reviews.removeWhere((r) => r.id == reviewId);

      // Refresh summary
      await loadReviewSummary(lawyerId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete review: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mark review as helpful
  Future<void> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      _clearError();

      await _reviewService.markReviewHelpful(reviewId, isHelpful);

      // Update local review
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final currentReview = _reviews[index];
        final increment = isHelpful ? 1 : -1;
        _reviews[index] = currentReview.copyWith(
          isHelpful: isHelpful,
          helpfulCount: currentReview.helpfulCount + increment,
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to mark review as helpful: $e');
    }
  }

  // Check if client can review lawyer
  Future<bool> canClientReviewLawyer({
    required String clientId,
    required String lawyerId,
    String? gigId,
  }) async {
    try {
      return await _reviewService.canClientReviewLawyer(
        clientId: clientId,
        lawyerId: lawyerId,
        gigId: gigId,
      );
    } catch (e) {
      _setError('Failed to check review eligibility: $e');
      return false;
    }
  }

  // Load featured reviews
  Future<List<Review>> loadFeaturedReviews({
    String? lawyerId,
    int limit = 5,
  }) async {
    try {
      _clearError();
      return await _reviewService.getFeaturedReviews(
        lawyerId: lawyerId,
        limit: limit,
      );
    } catch (e) {
      _setError('Failed to load featured reviews: $e');
      return [];
    }
  }

  // Load reviews by tags
  Future<List<Review>> loadReviewsByTags({
    required String lawyerId,
    required List<String> tags,
    int limit = 10,
  }) async {
    try {
      _clearError();
      return await _reviewService.getReviewsByTags(
        lawyerId: lawyerId,
        tags: tags,
        limit: limit,
      );
    } catch (e) {
      _setError('Failed to load reviews by tags: $e');
      return [];
    }
  }

  // Get reviews by client
  Future<List<Review>> getClientReviews(String clientId) async {
    try {
      _clearError();
      return await _reviewService.getReviewsByClient(clientId);
    } catch (e) {
      _setError('Failed to load client reviews: $e');
      return [];
    }
  }

  // Clear all data
  void clear() {
    _reviews.clear();
    _reviewSummary = null;
    _lastDocument = null;
    _hasMoreReviews = true;
    _clearError();
    notifyListeners();
  }

  // Filter reviews by rating
  List<Review> getReviewsByRating(int rating) {
    return _reviews.where((review) => review.rating.round() == rating).toList();
  }

  // Filter reviews by tags
  List<Review> getReviewsByTag(String tag) {
    return _reviews.where((review) => review.tags.contains(tag)).toList();
  }

  // Get recent reviews
  List<Review> get recentReviews {
    return _reviews.where((review) => review.isRecent).toList();
  }

  // Get verified reviews
  List<Review> get verifiedReviews {
    return _reviews.where((review) => review.isVerified).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}