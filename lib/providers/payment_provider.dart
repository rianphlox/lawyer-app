import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  // State
  final List<Payment> _payments = [];
  PaymentSummary? _paymentSummary;
  bool _isLoading = false;
  String? _error;
  Payment? _currentPayment;

  // Getters
  List<Payment> get payments => _payments;
  PaymentSummary? get paymentSummary => _paymentSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Payment? get currentPayment => _currentPayment;

  // Create a new payment
  Future<Payment?> createPayment({
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
      _setLoading(true);
      _clearError();

      // Validate payment amount
      if (!PaymentService.isValidPaymentAmount(amount)) {
        throw Exception('Invalid payment amount');
      }

      final payment = await _paymentService.createPayment(
        clientId: clientId,
        lawyerId: lawyerId,
        amount: amount,
        type: type,
        description: description,
        gigId: gigId,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      _currentPayment = payment;
      _payments.insert(0, payment);
      notifyListeners();

      return payment;
    } catch (e) {
      _setError('Failed to create payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment
  Future<Payment?> processPayment(String paymentId) async {
    try {
      _setLoading(true);
      _clearError();

      final payment = await _paymentService.processPayment(paymentId);

      // Update local payment
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = payment;
      }

      _currentPayment = payment;
      notifyListeners();

      return payment;
    } catch (e) {
      _setError('Failed to process payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      _clearError();

      final payment = await _paymentService.getPayment(paymentId);
      if (payment != null) {
        _currentPayment = payment;
        notifyListeners();
      }

      return payment;
    } catch (e) {
      _setError('Failed to get payment: $e');
      return null;
    }
  }

  // Load payments for user
  void loadPaymentsForUser({
    required String userId,
    required bool isLawyer,
    PaymentStatus? status,
    int limit = 20,
  }) {
    _clearError();

    final stream = _paymentService.getPaymentsForUser(
      userId: userId,
      isLawyer: isLawyer,
      status: status,
      limit: limit,
    );

    stream.listen(
      (payments) {
        _payments.clear();
        _payments.addAll(payments);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load payments: $error');
      },
    );
  }

  // Load payment summary
  Future<void> loadPaymentSummary(String lawyerId) async {
    try {
      _clearError();

      _paymentSummary = await _paymentService.getPaymentSummary(lawyerId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment summary: $e');
    }
  }

  // Cancel payment
  Future<bool> cancelPayment(String paymentId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      await _paymentService.cancelPayment(paymentId, reason);

      // Update local payment
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = _payments[index].copyWith(
          status: PaymentStatus.cancelled,
          processedAt: DateTime.now(),
          failureReason: reason,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to cancel payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Request refund
  Future<bool> requestRefund(String paymentId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      await _paymentService.requestRefund(paymentId, reason);

      // Update local payment
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = _payments[index].copyWith(
          status: PaymentStatus.refunded,
          processedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to request refund: $e');
      return false;
    } finally {
      _setLoading(false);
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
      _clearError();

      return await _paymentService.getPaymentsByDateRange(
        userId: userId,
        isLawyer: isLawyer,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
    } catch (e) {
      _setError('Failed to get payments by date range: $e');
      return [];
    }
  }

  // Get payment receipt
  Future<Map<String, dynamic>?> getPaymentReceipt(String paymentId) async {
    try {
      _clearError();

      return await _paymentService.getPaymentReceipt(paymentId);
    } catch (e) {
      _setError('Failed to get payment receipt: $e');
      return null;
    }
  }

  // Filter payments by status
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  // Filter payments by type
  List<Payment> getPaymentsByType(PaymentType type) {
    return _payments.where((payment) => payment.type == type).toList();
  }

  // Get pending payments
  List<Payment> get pendingPayments {
    return _payments.where((payment) => payment.status.isPending).toList();
  }

  // Get completed payments
  List<Payment> get completedPayments {
    return _payments.where((payment) => payment.status.isSuccessful).toList();
  }

  // Get failed payments
  List<Payment> get failedPayments {
    return _payments.where((payment) => payment.status.isFailed).toList();
  }

  // Calculate total earnings
  double get totalEarnings {
    return completedPayments.fold(
      0.0,
      (accumulator, payment) => accumulator + payment.lawyerEarning,
    );
  }

  // Calculate total spent (for clients)
  double get totalSpent {
    return completedPayments.fold(
      0.0,
      (accumulator, payment) => accumulator + payment.amount,
    );
  }

  // Get payments for current month
  List<Payment> get currentMonthPayments {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return _payments.where((payment) =>
        payment.createdAt.isAfter(startOfMonth) &&
        payment.createdAt.isBefore(endOfMonth.add(const Duration(days: 1)))).toList();
  }

  // Clear all data
  void clear() {
    _payments.clear();
    _paymentSummary = null;
    _currentPayment = null;
    _clearError();
    notifyListeners();
  }

  // Calculate platform fee preview
  double calculatePlatformFee(double amount) {
    return PaymentService.calculatePlatformFee(amount);
  }

  // Calculate lawyer earning preview
  double calculateLawyerEarning(double amount) {
    return PaymentService.calculateLawyerEarning(amount);
  }

  // Validate payment amount
  bool isValidPaymentAmount(double amount) {
    return PaymentService.isValidPaymentAmount(amount);
  }

  // Search payments
  List<Payment> searchPayments(String query) {
    if (query.isEmpty) return _payments;

    final lowerQuery = query.toLowerCase();
    return _payments.where((payment) =>
        payment.description.toLowerCase().contains(lowerQuery) ||
        payment.transactionId?.toLowerCase().contains(lowerQuery) == true ||
        payment.formattedAmount.contains(query)).toList();
  }

  // Get payment analytics
  Map<String, dynamic> getPaymentAnalytics() {
    if (_payments.isEmpty) {
      return {
        'totalAmount': 0.0,
        'averageAmount': 0.0,
        'successRate': 0.0,
        'totalCount': 0,
        'monthlyTrend': <String, double>{},
      };
    }

    final totalAmount = _payments.fold(0.0, (accumulator, p) => accumulator + p.amount);
    final averageAmount = totalAmount / _payments.length;
    final successfulPayments = _payments.where((p) => p.status.isSuccessful).length;
    final successRate = successfulPayments / _payments.length;

    // Calculate monthly trend (last 6 months)
    final monthlyTrend = <String, double>{};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final monthlyPayments = _payments.where((p) =>
          p.createdAt.year == month.year &&
          p.createdAt.month == month.month &&
          p.status.isSuccessful).toList();

      monthlyTrend[monthKey] = monthlyPayments.fold(0.0, (accumulator, p) => accumulator + p.amount);
    }

    return {
      'totalAmount': totalAmount,
      'averageAmount': averageAmount,
      'successRate': successRate,
      'totalCount': _payments.length,
      'monthlyTrend': monthlyTrend,
    };
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