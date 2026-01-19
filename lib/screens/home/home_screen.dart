import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/lawyer_card.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/floating_ai_button.dart';
import '../../models/lawyer.dart';
import '../../models/gig.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = AppConstants.legalSpecialties.first;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLawyer = authProvider.isLawyer;
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  expandedHeight: 320,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with user info and notification
                          FadeInDown(
                            duration: const Duration(milliseconds: 600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.name ?? (isLawyer ? 'Adv. User' : 'Client'),
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppTheme.borderLight,
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          // Handle notification tap
                                        },
                                        icon: const Icon(
                                          Icons.notifications_outlined,
                                          color: AppTheme.textPrimary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.errorColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Main title and search
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isLawyer
                                            ? 'Find your next\nhigh-value case'
                                            : 'Find your\ntrusted lawyers',
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Search field
                                CustomTextField(
                                  controller: _searchController,
                                  label: '',
                                  hintText: isLawyer
                                      ? 'Search by case title...'
                                      : 'Search by lawyer name...',
                                  prefixIcon: Icons.search_rounded,
                                  onChanged: (value) {
                                    // Handle search
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick stats for lawyers
                if (isLawyer) ...[
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatsCard(
                                'Total Earnings',
                                '\$12,450',
                                Icons.account_balance_wallet_outlined,
                                () => context.go(AppRoutes.earnings),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatsCard(
                                'Active Apps',
                                '8',
                                Icons.work_outline_rounded,
                                () => context.go(AppRoutes.applications),
                                isHighlight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],

                // Specialties/Categories
                SliverToBoxAdapter(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 500),
                    child: SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: AppConstants.legalSpecialties.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final specialty = AppConstants.legalSpecialties[index];
                          final isSelected = _selectedSpecialty == specialty;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSpecialty = specialty;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                specialty,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Section header
                SliverToBoxAdapter(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isLawyer ? 'Recommended Gigs' : 'Top Rated Lawyers',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle see all
                            },
                            child: Text(
                              'See all',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Content list
                if (isLawyer) ...[
                  // Gigs for lawyers
                  SliverList.builder(
                    itemCount: MockData.mockGigs.length,
                    itemBuilder: (context, index) {
                      final gig = MockData.mockGigs[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 700 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: GigCard(
                            gig: gig,
                            onTap: () => context.go(
                              AppRoutes.gigDetails,
                              extra: gig,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // Lawyers for clients
                  SliverList.builder(
                    itemCount: MockData.mockLawyers.length,
                    itemBuilder: (context, index) {
                      final lawyer = MockData.mockLawyers[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 700 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: LawyerCard(
                            lawyer: lawyer,
                            onTap: () => context.go(
                              AppRoutes.lawyerDetails,
                              extra: lawyer,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Bottom spacing for navigation
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // Bottom Navigation
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  // Already on home
                  break;
                case 1:
                  context.go(isLawyer ? AppRoutes.earnings : AppRoutes.postGig);
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

          // Floating AI Button
          floatingActionButton: FloatingAiButton(
            onPressed: () => context.go(AppRoutes.aiChat),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        );
      },
    );
  }

  Widget _buildStatsCard(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool isHighlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isHighlight ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighlight ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}