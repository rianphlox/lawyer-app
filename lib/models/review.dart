import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String lawyerId;
  final String clientId;
  final String clientName;
  final String clientImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final String? gigId;
  final List<String> tags;
  final bool isHelpful;
  final int helpfulCount;

  const Review({
    required this.id,
    required this.lawyerId,
    required this.clientId,
    required this.clientName,
    required this.clientImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.gigId,
    this.tags = const [],
    this.isHelpful = false,
    this.helpfulCount = 0,
  });

  Review copyWith({
    String? id,
    String? lawyerId,
    String? clientId,
    String? clientName,
    String? clientImageUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? gigId,
    List<String>? tags,
    bool? isHelpful,
    int? helpfulCount,
  }) {
    return Review(
      id: id ?? this.id,
      lawyerId: lawyerId ?? this.lawyerId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientImageUrl: clientImageUrl ?? this.clientImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      gigId: gigId ?? this.gigId,
      tags: tags ?? this.tags,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lawyerId': lawyerId,
      'clientId': clientId,
      'clientName': clientName,
      'clientImageUrl': clientImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVerified': isVerified,
      'gigId': gigId,
      'tags': tags,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      lawyerId: json['lawyerId'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      clientImageUrl: json['clientImageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      isVerified: json['isVerified'] ?? false,
      gigId: json['gigId'],
      tags: List<String>.from(json['tags'] ?? []),
      isHelpful: json['isHelpful'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isRecent => DateTime.now().difference(createdAt).inDays <= 7;
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<Review> recentReviews;
  final List<String> commonTags;

  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.recentReviews,
    required this.commonTags,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'recentReviews': recentReviews.map((r) => r.toJson()).toList(),
      'commonTags': commonTags,
    };
  }

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {}),
      recentReviews: (json['recentReviews'] as List<dynamic>?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
      commonTags: List<String>.from(json['commonTags'] ?? []),
    );
  }
}