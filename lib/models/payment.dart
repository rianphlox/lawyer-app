import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isSuccessful => this == PaymentStatus.completed;
  bool get isPending => this == PaymentStatus.pending || this == PaymentStatus.processing;
  bool get isFailed => this == PaymentStatus.failed || this == PaymentStatus.cancelled;
}

enum PaymentType {
  consultation,
  hourlyRate,
  fixedPrice,
  retainer,
  milestone;

  String get displayName {
    switch (this) {
      case PaymentType.consultation:
        return 'Consultation';
      case PaymentType.hourlyRate:
        return 'Hourly Rate';
      case PaymentType.fixedPrice:
        return 'Fixed Price';
      case PaymentType.retainer:
        return 'Retainer';
      case PaymentType.milestone:
        return 'Milestone Payment';
    }
  }
}

class Payment {
  final String id;
  final String clientId;
  final String lawyerId;
  final String? gigId;
  final double amount;
  final double platformFee;
  final double lawyerEarning;
  final PaymentStatus status;
  final PaymentType type;
  final String description;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? paymentMethodId;
  final String currency;
  final Map<String, dynamic> metadata;
  final String? failureReason;

  const Payment({
    required this.id,
    required this.clientId,
    required this.lawyerId,
    this.gigId,
    required this.amount,
    required this.platformFee,
    required this.lawyerEarning,
    required this.status,
    required this.type,
    required this.description,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.transactionId,
    this.paymentMethodId,
    this.currency = 'USD',
    this.metadata = const {},
    this.failureReason,
  });

  Payment copyWith({
    String? id,
    String? clientId,
    String? lawyerId,
    String? gigId,
    double? amount,
    double? platformFee,
    double? lawyerEarning,
    PaymentStatus? status,
    PaymentType? type,
    String? description,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? transactionId,
    String? paymentMethodId,
    String? currency,
    Map<String, dynamic>? metadata,
    String? failureReason,
  }) {
    return Payment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      lawyerId: lawyerId ?? this.lawyerId,
      gigId: gigId ?? this.gigId,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      lawyerEarning: lawyerEarning ?? this.lawyerEarning,
      status: status ?? this.status,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      currency: currency ?? this.currency,
      metadata: metadata ?? this.metadata,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'lawyerId': lawyerId,
      'gigId': gigId,
      'amount': amount,
      'platformFee': platformFee,
      'lawyerEarning': lawyerEarning,
      'status': status.name,
      'type': type.name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionId': transactionId,
      'paymentMethodId': paymentMethodId,
      'currency': currency,
      'metadata': metadata,
      'failureReason': failureReason,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      lawyerId: json['lawyerId'] ?? '',
      gigId: json['gigId'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      platformFee: (json['platformFee'] ?? 0.0).toDouble(),
      lawyerEarning: (json['lawyerEarning'] ?? 0.0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.consultation,
      ),
      description: json['description'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (json['processedAt'] as Timestamp?)?.toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      transactionId: json['transactionId'],
      paymentMethodId: json['paymentMethodId'],
      currency: json['currency'] ?? 'USD',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      failureReason: json['failureReason'],
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedPlatformFee => '\$${platformFee.toStringAsFixed(2)}';
  String get formattedLawyerEarning => '\$${lawyerEarning.toStringAsFixed(2)}';

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

  bool get canBeRefunded {
    return status == PaymentStatus.completed &&
           completedAt != null &&
           DateTime.now().difference(completedAt!).inDays <= 30;
  }
}

class PaymentSummary {
  final double totalEarnings;
  final double totalPaid;
  final double pendingAmount;
  final int totalTransactions;
  final int completedTransactions;
  final int pendingTransactions;
  final double averageTransactionAmount;
  final List<Payment> recentPayments;

  const PaymentSummary({
    required this.totalEarnings,
    required this.totalPaid,
    required this.pendingAmount,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.averageTransactionAmount,
    required this.recentPayments,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'totalPaid': totalPaid,
      'pendingAmount': pendingAmount,
      'totalTransactions': totalTransactions,
      'completedTransactions': completedTransactions,
      'pendingTransactions': pendingTransactions,
      'averageTransactionAmount': averageTransactionAmount,
      'recentPayments': recentPayments.map((p) => p.toJson()).toList(),
    };
  }

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0.0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      completedTransactions: json['completedTransactions'] ?? 0,
      pendingTransactions: json['pendingTransactions'] ?? 0,
      averageTransactionAmount: (json['averageTransactionAmount'] ?? 0.0).toDouble(),
      recentPayments: (json['recentPayments'] as List<dynamic>?)
              ?.map((p) => Payment.fromJson(p))
              .toList() ??
          [],
    );
  }

  String get formattedTotalEarnings => '\$${totalEarnings.toStringAsFixed(2)}';
  String get formattedTotalPaid => '\$${totalPaid.toStringAsFixed(2)}';
  String get formattedPendingAmount => '\$${pendingAmount.toStringAsFixed(2)}';
  String get formattedAverageTransaction => '\$${averageTransactionAmount.toStringAsFixed(2)}';
}