import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/payment_card.dart';
import '../../widgets/payment_summary_card.dart';
import 'payment_details_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  PaymentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final user = authProvider.user;

    if (user != null) {
      final isLawyer = user.role.isLawyer;

      paymentProvider.loadPaymentsForUser(
        userId: user.id,
        isLawyer: isLawyer,
      );

      if (isLawyer) {
        paymentProvider.loadPaymentSummary(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Pending'),
            Tab(text: 'Failed'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer2<PaymentProvider, AuthProvider>(
        builder: (context, paymentProvider, authProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load payments',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentProvider.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = authProvider.user;
          final isLawyer = user?.role.isLawyer ?? false;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllPaymentsTab(paymentProvider, isLawyer),
              _buildFilteredPaymentsTab(
                  paymentProvider, PaymentStatus.completed, isLawyer),
              _buildFilteredPaymentsTab(
                  paymentProvider, PaymentStatus.pending, isLawyer),
              _buildFailedPaymentsTab(paymentProvider, isLawyer),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllPaymentsTab(PaymentProvider paymentProvider, bool isLawyer) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: CustomScrollView(
        slivers: [
          // Payment summary (for lawyers)
          if (isLawyer && paymentProvider.paymentSummary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentSummaryCard(
                  summary: paymentProvider.paymentSummary!,
                  isLawyer: isLawyer,
                  onViewAll: () => _tabController.animateTo(1),
                ),
              ),
            ),

          // Payments list
          if (paymentProvider.payments.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No payments yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLawyer
                          ? 'Start taking on cases to see your earnings here'
                          : 'Make your first payment to see transactions here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payment = paymentProvider.payments[index];
                    return PaymentCard(
                      payment: payment,
                      showLawyerInfo: isLawyer,
                      showClientInfo: !isLawyer,
                      onTap: () => _navigateToPaymentDetails(payment),
                    );
                  },
                  childCount: paymentProvider.payments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilteredPaymentsTab(
      PaymentProvider paymentProvider, PaymentStatus status, bool isLawyer) {
    final filteredPayments = paymentProvider.getPaymentsByStatus(status);

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: filteredPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${status.displayName.toLowerCase()} payments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = filteredPayments[index];
                return PaymentCard(
                  payment: payment,
                  showLawyerInfo: isLawyer,
                  showClientInfo: !isLawyer,
                  onTap: () => _navigateToPaymentDetails(payment),
                );
              },
            ),
    );
  }

  Widget _buildFailedPaymentsTab(PaymentProvider paymentProvider, bool isLawyer) {
    final failedPayments = paymentProvider.failedPayments;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: failedPayments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No failed payments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All your payments have been successful!',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: failedPayments.length,
              itemBuilder: (context, index) {
                final payment = failedPayments[index];
                return PaymentCard(
                  payment: payment,
                  showLawyerInfo: isLawyer,
                  showClientInfo: !isLawyer,
                  onTap: () => _navigateToPaymentDetails(payment),
                );
              },
            ),
    );
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Icons.access_time;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.undo;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Payments'),
              leading: Radio<PaymentStatus?>(
                value: null,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  Navigator.of(context).pop();
                  // Apply filter
                },
              ),
            ),
            ...PaymentStatus.values.map((status) {
              return ListTile(
                title: Text(status.displayName),
                leading: Radio<PaymentStatus?>(
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    Navigator.of(context).pop();
                    // Apply filter
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToPaymentDetails(Payment payment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(payment: payment),
      ),
    );
  }
}