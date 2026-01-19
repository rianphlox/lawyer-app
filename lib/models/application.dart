import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class GigApplication {
  final String id;
  final String gigId;
  final String lawyerId;
  final String lawyerName;
  final String coverLetter;
  final double proposedRate;
  final int estimatedDays;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? respondedAt;
  final String? clientFeedback;
  final List<String> attachments;

  const GigApplication({
    required this.id,
    required this.gigId,
    required this.lawyerId,
    required this.lawyerName,
    required this.coverLetter,
    required this.proposedRate,
    required this.estimatedDays,
    required this.status,
    required this.appliedAt,
    this.respondedAt,
    this.clientFeedback,
    this.attachments = const [],
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(appliedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'coverLetter': coverLetter,
      'proposedRate': proposedRate,
      'estimatedDays': estimatedDays,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'clientFeedback': clientFeedback,
      'attachments': attachments,
    };
  }

  factory GigApplication.fromJson(Map<String, dynamic> json) {
    return GigApplication(
      id: json['id'] ?? '',
      gigId: json['gigId'] ?? '',
      lawyerId: json['lawyerId'] ?? '',
      lawyerName: json['lawyerName'] ?? '',
      coverLetter: json['coverLetter'] ?? '',
      proposedRate: (json['proposedRate'] ?? 0.0).toDouble(),
      estimatedDays: json['estimatedDays'] ?? 0,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: (json['appliedAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
      clientFeedback: json['clientFeedback'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  GigApplication copyWith({
    String? id,
    String? gigId,
    String? lawyerId,
    String? lawyerName,
    String? coverLetter,
    double? proposedRate,
    int? estimatedDays,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? respondedAt,
    String? clientFeedback,
    List<String>? attachments,
  }) {
    return GigApplication(
      id: id ?? this.id,
      gigId: gigId ?? this.gigId,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      coverLetter: coverLetter ?? this.coverLetter,
      proposedRate: proposedRate ?? this.proposedRate,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      clientFeedback: clientFeedback ?? this.clientFeedback,
      attachments: attachments ?? this.attachments,
    );
  }
}