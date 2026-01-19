import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import '../core/constants.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock payment gateway integration
  static const double _platformFeeRate = 0.05; // 5% platform fee

  // Create a new payment
  Future<Payment> createPayment({
    required String clientId,
    required String lawyerId,
    required double amount,
    required PaymentType type,
    required String description,
    String? gigId,
    String? paymentMethodId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final paymentId = _firestore.collection(AppConstants.paymentsCollection).doc().id;

      final platformFee = amount * _platformFeeRate;
      final lawyerEarning = amount - platformFee;

      final payment = Payment(
        id: paymentId,
        clientId: clientId,
        lawyerId: lawyerId,
        gigId: gigId,
        amount: amount,
        platformFee: platformFee,
        lawyerEarning: lawyerEarning,
        status: PaymentStatus.pending,
        type: type,
        description: description,
        createdAt: DateTime.now(),
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .set(payment.toJson());

      return payment;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Process payment (mock implementation)
  Future<Payment> processPayment(String paymentId) async {
    try {
      final paymentDoc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) {
        throw Exception('Payment not found');
      }

      final payment = Payment.fromJson(paymentDoc.data()!);

      if (payment.status != PaymentStatus.pending) {
        throw Exception('Payment is not in pending status');
      }

      // Mock payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Simulate 95% success rate
      final isSuccess = DateTime.now().millisecond % 100 < 95;

      final updatedPayment = payment.copyWith(
        status: isSuccess ? PaymentStatus.completed : PaymentStatus.failed,
        processedAt: DateTime.now(),
        completedAt: isSuccess ? DateTime.now() : null,
        transactionId: isSuccess ? 'txn_${DateTime.now().millisecondsSinceEpoch}' : null,
        failureReason: isSuccess ? null : 'Payment declined by bank',
      );

      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update(updatedPayment.toJson());

      return updatedPayment;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Get payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Payment.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // Get payments for a user (client or lawyer)
  Stream<List<Payment>> getPaymentsForUser({
    required String userId,
    required bool isLawyer,
    PaymentStatus? status,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(AppConstants.paymentsCollection)
        .where(isLawyer ? 'lawyerId' : 'clientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.limit(limit).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  // Get payment summary for a lawyer
  Future<PaymentSummary> getPaymentSummary(String lawyerId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('lawyerId', isEqualTo: lawyerId)
          .get();

      if (snapshot.docs.isEmpty) {
        return const PaymentSummary(
          totalEarnings: 0.0,
          totalPaid: 0.0,
          pendingAmount: 0.0,
          totalTransactions: 0,
          completedTransactions: 0,
          pendingTransactions: 0,
          averageTransactionAmount: 0.0,
          recentPayments: [],
        );
      }

      final payments = snapshot.docs
          .map((doc) => Payment.fromJson(doc.data()))
          .toList();

      final completedPayments = payments
          .where((p) => p.status == PaymentStatus.completed)
          .toList();

      final pendingPayments = payments
          .where((p) => p.status.isPending)
          .toList();

      final totalEarnings = completedPayments.fold(
        0.0,
        (accumulator, payment) => accumulator + payment.lawyerEarning,
      );

      final totalPaid = totalEarnings; // In real app, this would be different
      final pendingAmount = pendingPayments.fold(
        0.0,
        (accumulator, payment) => accumulator + payment.lawyerEarning,
      );

      final averageTransactionAmount = completedPayments.isNotEmpty
          ? completedPayments.fold(0.0, (accumulator, p) => accumulator + p.amount) / completedPayments.length
          : 0.0;

      final recentPayments = payments
          .where((p) => DateTime.now().difference(p.createdAt).inDays <= 30)
          .take(5)
          .toList();

      return PaymentSummary(
        totalEarnings: totalEarnings,
        totalPaid: totalPaid,
        pendingAmount: pendingAmount,
        totalTransactions: payments.length,
        completedTransactions: completedPayments.length,
        pendingTransactions: pendingPayments.length,
        averageTransactionAmount: averageTransactionAmount,
        recentPayments: recentPayments,
      );
    } catch (e) {
      throw Exception('Failed to get payment summary: $e');
    }
  }

  // Cancel payment
  Future<void> cancelPayment(String paymentId, String reason) async {
    try {
      final paymentDoc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) {
        throw Exception('Payment not found');
      }

      final payment = Payment.fromJson(paymentDoc.data()!);

      if (payment.status != PaymentStatus.pending) {
        throw Exception('Only pending payments can be cancelled');
      }

      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': PaymentStatus.cancelled.name,
        'processedAt': Timestamp.fromDate(DateTime.now()),
        'failureReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to cancel payment: $e');
    }
  }

  // Request refund
  Future<void> requestRefund(String paymentId, String reason) async {
    try {
      final paymentDoc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) {
        throw Exception('Payment not found');
      }

      final payment = Payment.fromJson(paymentDoc.data()!);

      if (!payment.canBeRefunded) {
        throw Exception('Payment cannot be refunded');
      }

      // In a real app, this would integrate with payment gateway for refunds
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': PaymentStatus.refunded.name,
        'processedAt': Timestamp.fromDate(DateTime.now()),
        'metadata.refundReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }

  // Get payment statistics for admin
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .get();

      final payments = snapshot.docs
          .map((doc) => Payment.fromJson(doc.data()))
          .toList();

      final completedPayments = payments
          .where((p) => p.status == PaymentStatus.completed)
          .toList();

      final totalVolume = payments.fold(0.0, (accumulator, p) => accumulator + p.amount);
      final totalRevenue = payments.fold(0.0, (accumulator, p) => accumulator + p.platformFee);
      final successRate = payments.isNotEmpty
          ? completedPayments.length / payments.length
          : 0.0;

      final recentPayments = payments
          .where((p) => DateTime.now().difference(p.createdAt).inDays <= 7)
          .length;

      return {
        'totalVolume': totalVolume,
        'totalRevenue': totalRevenue,
        'totalTransactions': payments.length,
        'completedTransactions': completedPayments.length,
        'successRate': successRate,
        'recentTransactions': recentPayments,
        'averageTransactionSize': payments.isNotEmpty ? totalVolume / payments.length : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get payment statistics: $e');
    }
  }

  // Get payments by date range
  Future<List<Payment>> getPaymentsByDateRange({
    required String userId,
    required bool isLawyer,
    required DateTime startDate,
    required DateTime endDate,
    PaymentStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.paymentsCollection)
          .where(isLawyer ? 'lawyerId' : 'clientId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments by date range: $e');
    }
  }

  // Update payment status (for admin)
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status, {String? reason}) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'processedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (status == PaymentStatus.completed) {
        updates['completedAt'] = Timestamp.fromDate(DateTime.now());
        updates['transactionId'] = 'admin_txn_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (reason != null) {
        updates['failureReason'] = reason;
      }

      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Calculate platform fee
  static double calculatePlatformFee(double amount) {
    return amount * _platformFeeRate;
  }

  // Calculate lawyer earning
  static double calculateLawyerEarning(double amount) {
    return amount - calculatePlatformFee(amount);
  }

  // Validate payment amount
  static bool isValidPaymentAmount(double amount) {
    return amount > 0 && amount <= 50000; // Max $50,000 per transaction
  }

  // Get payment receipt data
  Future<Map<String, dynamic>> getPaymentReceipt(String paymentId) async {
    try {
      final payment = await getPayment(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      // Get lawyer and client info
      final lawyerDoc = await _firestore
          .collection(AppConstants.lawyersCollection)
          .doc(payment.lawyerId)
          .get();

      final clientDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(payment.clientId)
          .get();

      return {
        'payment': payment.toJson(),
        'lawyer': lawyerDoc.data(),
        'client': clientDoc.data(),
        'receiptNumber': 'RCP-${payment.id.substring(0, 8).toUpperCase()}',
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate payment receipt: $e');
    }
  }
}