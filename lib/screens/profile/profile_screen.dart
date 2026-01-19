import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isLawyer = authProvider.isLawyer;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.go(AppRoutes.settings),
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Profile Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Profile Image
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: AppTheme.borderLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: user?.profileImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user!.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppTheme.textSecondary,
                                        size: 40,
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppTheme.textSecondary,
                                        size: 40,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppTheme.textSecondary,
                                      size: 40,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name and Role
                          Text(
                            user?.name ?? 'User Name',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user?.role.displayName ?? 'Client',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats Row
                          if (isLawyer) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStat(context, 'Cases', '32'),
                                _buildStat(context, 'Rating', '4.8'),
                                _buildStat(context, 'Years', '8'),
                              ],
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStat(context, 'Cases', '5'),
                                _buildStat(context, 'Reviews', '12'),
                                _buildStat(context, 'Saved', '24'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Menu Items
                  ...List.generate(_getMenuItems(isLawyer).length, (index) {
                    final item = _getMenuItems(isLawyer)[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: 300 + (index * 100)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _buildMenuItem(
                          context,
                          item['icon'] as IconData,
                          item['title'] as String,
                          item['subtitle'] as String?,
                          item['onTap'] as VoidCallback?,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Logout Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 300 + (_getMenuItems(isLawyer).length * 100)),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showLogoutDialog(context, authProvider),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: AppTheme.errorColor,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          bottomNavigationBar: BottomNavBar(
            currentIndex: 3,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.home);
                  break;
                case 1:
                  context.go(isLawyer ? AppRoutes.earnings : AppRoutes.postGig);
                  break;
                case 2:
                  context.go(AppRoutes.messaging);
                  break;
                case 3:
                  // Already on profile
                  break;
              }
            },
            isLawyer: isLawyer,
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMenuItems(bool isLawyer) {
    final commonItems = [
      {
        'icon': Icons.edit_outlined,
        'title': 'Edit Profile',
        'subtitle': 'Update your personal information',
        'onTap': () {
          // Handle edit profile
        },
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your notification preferences',
        'onTap': () {
          // Handle notifications
        },
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Privacy & Security',
        'subtitle': 'Manage your account security',
        'onTap': () {
          // Handle privacy
        },
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'onTap': () {
          // Handle help
        },
      },
    ];

    final lawyerSpecificItems = [
      {
        'icon': Icons.verified_outlined,
        'title': 'Verification Status',
        'subtitle': 'Manage your professional verification',
        'onTap': () {
          // Handle verification
        },
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'Analytics',
        'subtitle': 'View your performance metrics',
        'onTap': () {
          // Handle analytics
        },
      },
    ];

    final clientSpecificItems = [
      {
        'icon': Icons.bookmark_outline_rounded,
        'title': 'Saved Lawyers',
        'subtitle': 'View your bookmarked lawyers',
        'onTap': () {
          // Handle saved lawyers
        },
      },
      {
        'icon': Icons.history_rounded,
        'title': 'Case History',
        'subtitle': 'View your past consultations',
        'onTap': () {
          // Handle case history
        },
      },
    ];

    return [
      ...commonItems.take(1),
      ...(isLawyer ? lawyerSpecificItems : clientSpecificItems),
      ...commonItems.skip(1),
    ];
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                context.go(AppRoutes.landing);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}