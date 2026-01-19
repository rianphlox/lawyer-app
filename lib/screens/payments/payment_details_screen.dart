import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final Payment payment;

  const PaymentDetailsScreen({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'receipt',
                child: ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('View Receipt'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_id',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy Transaction ID'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (payment.canBeRefunded)
                const PopupMenuItem(
                  value: 'refund',
                  child: ListTile(
                    leading: Icon(Icons.undo, color: Colors.orange),
                    title: Text('Request Refund'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatusIcon(payment.status),
                    const SizedBox(height: 16),
                    Text(
                      payment.formattedAmount,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getAmountColor(payment.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      payment.status.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _getStatusColor(payment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.type.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Information
            _buildInfoSection(
              context,
              'Payment Information',
              [
                _InfoItem('Description', payment.description),
                _InfoItem('Payment ID', payment.id),
                if (payment.transactionId != null)
                  _InfoItem('Transaction ID', payment.transactionId!),
                _InfoItem('Created', _formatDateTime(payment.createdAt)),
                if (payment.processedAt != null)
                  _InfoItem('Processed', _formatDateTime(payment.processedAt!)),
                if (payment.completedAt != null)
                  _InfoItem('Completed', _formatDateTime(payment.completedAt!)),
              ],
            ),

            const SizedBox(height: 20),

            // Amount Breakdown
            _buildInfoSection(
              context,
              'Amount Breakdown',
              [
                _InfoItem('Subtotal', payment.formattedAmount),
                _InfoItem('Platform Fee (5%)', payment.formattedPlatformFee),
                _InfoItem(
                  'Lawyer Earning',
                  payment.formattedLawyerEarning,
                  highlight: true,
                ),
                _InfoItem('Currency', payment.currency.toUpperCase()),
              ],
            ),

            const SizedBox(height: 20),

            // Failure Information (if applicable)
            if (payment.status.isFailed && payment.failureReason != null) ...[
              _buildInfoSection(
                context,
                'Failure Information',
                [
                  _InfoItem('Reason', payment.failureReason!),
                ],
                isError: true,
              ),
              const SizedBox(height: 20),
            ],

            // Metadata (if any)
            if (payment.metadata.isNotEmpty) ...[
              _buildInfoSection(
                context,
                'Additional Information',
                payment.metadata.entries
                    .map((entry) => _InfoItem(
                          entry.key,
                          entry.value.toString(),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case PaymentStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        icon = Icons.error;
        color = Colors.red;
        break;
      case PaymentStatus.refunded:
        icon = Icons.undo;
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<_InfoItem> items, {
    bool isError = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isError)
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                if (isError) const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: item.highlight ? FontWeight.bold : null,
                            color: item.highlight
                                ? Colors.green
                                : isError
                                    ? Colors.red
                                    : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer2<PaymentProvider, AuthProvider>(
      builder: (context, paymentProvider, authProvider, child) {
        final user = authProvider.user;
        final isClient = user?.role.name == 'client';

        return Column(
          children: [
            // Cancel Button (for pending payments)
            if (payment.status == PaymentStatus.pending)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, paymentProvider),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Payment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

            // Refund Button (for completed payments, clients only)
            if (payment.canBeRefunded && isClient) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRefundDialog(context, paymentProvider),
                  icon: const Icon(Icons.undo),
                  label: const Text('Request Refund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            // Process Payment Button (for admin/testing)
            if (payment.status == PaymentStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: paymentProvider.isLoading
                      ? null
                      : () => _processPayment(context, paymentProvider),
                  icon: paymentProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payment),
                  label: const Text('Process Payment'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Colors.orange;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  Color _getAmountColor(PaymentStatus status) {
    return _getStatusColor(status);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'receipt':
        _showReceipt(context);
        break;
      case 'copy_id':
        _copyTransactionId(context);
        break;
      case 'refund':
        _showRefundDialog(context, context.read<PaymentProvider>());
        break;
    }
  }

  void _showReceipt(BuildContext context) {
    // TODO: Implement receipt view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt feature coming soon')),
    );
  }

  void _copyTransactionId(BuildContext context) {
    if (payment.transactionId != null) {
      Clipboard.setData(ClipboardData(text: payment.transactionId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ID copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transaction ID available')),
      );
    }
  }

  void _showCancelDialog(BuildContext context, PaymentProvider paymentProvider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this payment?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Payment'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await paymentProvider.cancelPayment(
                payment.id,
                reasonController.text.trim().isEmpty
                    ? 'Cancelled by user'
                    : reasonController.text.trim(),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Payment cancelled successfully'
                          : 'Failed to cancel payment',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, PaymentProvider paymentProvider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You can request a refund within 30 days of payment completion. '
              'Please provide a reason for your refund request.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for refund',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              Navigator.of(context).pop();

              final success = await paymentProvider.requestRefund(
                payment.id,
                reasonController.text.trim(),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Refund request submitted successfully'
                          : 'Failed to submit refund request',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Refund'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, PaymentProvider paymentProvider) async {
    final payment = await paymentProvider.processPayment(this.payment.id);

    if (context.mounted) {
      if (payment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment ${payment.status.displayName.toLowerCase()}',
            ),
            backgroundColor: payment.status.isSuccessful
                ? Colors.green
                : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoItem {
  final String label;
  final String value;
  final bool highlight;

  const _InfoItem(this.label, this.value, {this.highlight = false});
}