import 'package:cloud_firestore/cloud_firestore.dart';

enum GigStatus {
  open,
  closed,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case GigStatus.open:
        return 'Open';
      case GigStatus.closed:
        return 'Closed';
      case GigStatus.inProgress:
        return 'In Progress';
      case GigStatus.completed:
        return 'Completed';
    }
  }
}

enum GigType {
  corporate,
  crime,
  family,
  property,
  immigration,
  intellectual;

  String get displayName {
    switch (this) {
      case GigType.corporate:
        return 'Corporate';
      case GigType.crime:
        return 'Crime';
      case GigType.family:
        return 'Family';
      case GigType.property:
        return 'Property';
      case GigType.immigration:
        return 'Immigration';
      case GigType.intellectual:
        return 'Intellectual Property';
    }
  }
}

class Gig {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String clientName;
  final String clientId;
  final GigType type;
  final GigStatus status;
  final DateTime postedAt;
  final DateTime? deadline;
  final List<String> requiredSkills;
  final List<String> applications;
  final String? assignedLawyerId;

  const Gig({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.clientName,
    required this.clientId,
    required this.type,
    required this.status,
    required this.postedAt,
    this.deadline,
    this.requiredSkills = const [],
    this.applications = const [],
    this.assignedLawyerId,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

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
      'title': title,
      'description': description,
      'budget': budget,
      'clientName': clientName,
      'clientId': clientId,
      'type': type.name,
      'status': status.name,
      'postedAt': Timestamp.fromDate(postedAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'requiredSkills': requiredSkills,
      'applications': applications,
      'assignedLawyerId': assignedLawyerId,
    };
  }

  factory Gig.fromJson(Map<String, dynamic> json) {
    return Gig(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: (json['budget'] ?? 0.0).toDouble(),
      clientName: json['clientName'] ?? '',
      clientId: json['clientId'] ?? '',
      type: GigType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GigType.corporate,
      ),
      status: GigStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GigStatus.open,
      ),
      postedAt: (json['postedAt'] as Timestamp).toDate(),
      deadline: json['deadline'] != null
          ? (json['deadline'] as Timestamp).toDate()
          : null,
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      applications: List<String>.from(json['applications'] ?? []),
      assignedLawyerId: json['assignedLawyerId'],
    );
  }

  Gig copyWith({
    String? id,
    String? title,
    String? description,
    double? budget,
    String? clientName,
    String? clientId,
    GigType? type,
    GigStatus? status,
    DateTime? postedAt,
    DateTime? deadline,
    List<String>? requiredSkills,
    List<String>? applications,
    String? assignedLawyerId,
  }) {
    return Gig(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      deadline: deadline ?? this.deadline,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      applications: applications ?? this.applications,
      assignedLawyerId: assignedLawyerId ?? this.assignedLawyerId,
    );
  }
}