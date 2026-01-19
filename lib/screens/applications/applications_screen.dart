import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/application.dart';
import '../../models/gig.dart';
import '../../widgets/bottom_nav_bar.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock applications data
  final List<Map<String, dynamic>> _applications = [
    {
      'id': 'a1',
      'gigTitle': 'Intellectual Property Dispute',
      'clientName': 'TechNova Solutions',
      'budget': 5000.0,
      'proposedRate': 200.0,
      'estimatedDays': 14,
      'status': ApplicationStatus.pending,
      'appliedAt': DateTime.now().subtract(const Duration(hours: 2)),
      'type': GigType.intellectual,
      'coverLetter': 'I have extensive experience in IP law and have successfully handled similar cases...',
    },
    {
      'id': 'a2',
      'gigTitle': 'Corporate Contract Review',
      'clientName': 'StartupXYZ Inc.',
      'budget': 2500.0,
      'proposedRate': 150.0,
      'estimatedDays': 7,
      'status': ApplicationStatus.accepted,
      'appliedAt': DateTime.now().subtract(const Duration(days: 3)),
      'type': GigType.corporate,
      'coverLetter': 'With over 8 years of corporate law experience, I can provide thorough contract analysis...',
      'clientFeedback': 'Excellent proposal! Looking forward to working with you.',
    },
    {
      'id': 'a3',
      'gigTitle': 'Family Law Mediation',
      'clientName': 'John & Sarah Smith',
      'budget': 1800.0,
      'proposedRate': 180.0,
      'estimatedDays': 10,
      'status': ApplicationStatus.rejected,
      'appliedAt': DateTime.now().subtract(const Duration(days: 5)),
      'type': GigType.family,
      'coverLetter': 'I specialize in family mediation and have a track record of peaceful resolutions...',
      'clientFeedback': 'We decided to go with a local attorney.',
    },
    {
      'id': 'a4',
      'gigTitle': 'Real Estate Transaction',
      'clientName': 'PropertyCorp LLC',
      'budget': 3200.0,
      'proposedRate': 175.0,
      'estimatedDays': 12,
      'status': ApplicationStatus.pending,
      'appliedAt': DateTime.now().subtract(const Duration(days: 1)),
      'type': GigType.property,
      'coverLetter': 'Real estate law is my specialty. I have closed over 200 transactions...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLawyer = authProvider.isLawyer;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Text(
                          'Applications',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_applications.length} total',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            _getApplicationsByStatus(ApplicationStatus.pending).length.toString(),
                            Icons.schedule_rounded,
                            AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Accepted',
                            _getApplicationsByStatus(ApplicationStatus.accepted).length.toString(),
                            Icons.check_circle_outline_rounded,
                            AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rejected',
                            _getApplicationsByStatus(ApplicationStatus.rejected).length.toString(),
                            Icons.cancel_outlined,
                            AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tab Bar
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondary,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      tabs: const [
                        Tab(text: 'ALL'),
                        Tab(text: 'PENDING'),
                        Tab(text: 'ACCEPTED'),
                        Tab(text: 'REJECTED'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tab Bar View
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildApplicationsList(_applications),
                        _buildApplicationsList(_getApplicationsByStatus(ApplicationStatus.pending)),
                        _buildApplicationsList(_getApplicationsByStatus(ApplicationStatus.accepted)),
                        _buildApplicationsList(_getApplicationsByStatus(ApplicationStatus.rejected)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavBar(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.home);
                  break;
                case 1:
                  context.go(AppRoutes.earnings);
                  break;
                case 2:
                  context.go(AppRoutes.messaging);
                  break;
                case 3:
                  context.go(AppRoutes.profile);
                  break;
              }
            },
            isLawyer: isLawyer,
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<Map<String, dynamic>> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start applying to gigs to see your applications here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildApplicationCard(application),
        );
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final ApplicationStatus status = application['status'];
    final Color statusColor = _getStatusColor(status);
    final IconData statusIcon = _getStatusIcon(status);

    return GestureDetector(
      onTap: () => _showApplicationDetails(application),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(application['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (application['type'] as GigType).displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(application['type']),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title and client
            Text(
              application['gigTitle'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  application['clientName'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Application details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Your Rate',
                    '\$${application['proposedRate'].toInt()}/hr',
                    Icons.attach_money_rounded,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Timeline',
                    '${application['estimatedDays']} days',
                    Icons.schedule_outlined,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Applied',
                    _getTimeAgo(application['appliedAt']),
                    Icons.access_time_rounded,
                  ),
                ),
              ],
            ),

            // Client feedback (if available)
            if (application['clientFeedback'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Client Feedback',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      application['clientFeedback'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getApplicationsByStatus(ApplicationStatus status) {
    return _applications.where((app) => app['status'] == status).toList();
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppTheme.warningColor;
      case ApplicationStatus.accepted:
        return AppTheme.successColor;
      case ApplicationStatus.rejected:
        return AppTheme.errorColor;
      case ApplicationStatus.withdrawn:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.schedule_rounded;
      case ApplicationStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_outlined;
      case ApplicationStatus.withdrawn:
        return Icons.remove_circle_outline_rounded;
    }
  }

  Color _getTypeColor(GigType type) {
    switch (type) {
      case GigType.corporate:
        return AppTheme.primaryColor;
      case GigType.crime:
        return AppTheme.errorColor;
      case GigType.family:
        return AppTheme.successColor;
      case GigType.property:
        return AppTheme.warningColor;
      case GigType.immigration:
        return AppTheme.infoColor;
      case GigType.intellectual:
        return Colors.purple;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Application Details',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Application info
                      Text(
                        application['gigTitle'],
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Client: ${application['clientName']}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cover letter
                      Text(
                        'Your Proposal',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          application['coverLetter'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),

                      if (application['clientFeedback'] != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Client Feedback',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getStatusColor(application['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(application['status']).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            application['clientFeedback'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}