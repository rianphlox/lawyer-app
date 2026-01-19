import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/review_card.dart';
import '../../widgets/review_summary_card.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;

  const ReviewsScreen({
    super.key,
    required this.lawyerId,
    required this.lawyerName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final reviewProvider = context.read<ReviewProvider>();
    reviewProvider.loadReviews(widget.lawyerId, refresh: true);
    reviewProvider.loadReviewSummary(widget.lawyerId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final reviewProvider = context.read<ReviewProvider>();
      if (!reviewProvider.isLoading && reviewProvider.hasMoreReviews) {
        reviewProvider.loadReviews(widget.lawyerId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.lawyerName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Reviews'),
            Tab(text: 'Recent'),
            Tab(text: 'Verified'),
          ],
        ),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading && reviewProvider.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.error != null) {
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
                    'Failed to load reviews',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reviewProvider.error!,
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllReviewsTab(reviewProvider),
              _buildRecentReviewsTab(reviewProvider),
              _buildVerifiedReviewsTab(reviewProvider),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Only show add review button for clients
          if (authProvider.user?.role.name == 'client') {
            return FloatingActionButton.extended(
              onPressed: () => _showAddReviewDialog(authProvider),
              icon: const Icon(Icons.add),
              label: const Text('Add Review'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAllReviewsTab(ReviewProvider reviewProvider) {
    return RefreshIndicator(
      onRefresh: () => reviewProvider.loadReviews(widget.lawyerId, refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Review summary
          if (reviewProvider.reviewSummary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ReviewSummaryCard(
                  summary: reviewProvider.reviewSummary!,
                ),
              ),
            ),

          // Reviews list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < reviewProvider.reviews.length) {
                    return _buildReviewCard(reviewProvider.reviews[index]);
                  } else if (reviewProvider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!reviewProvider.hasMoreReviews) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('No more reviews'),
                      ),
                    );
                  }
                  return null;
                },
                childCount: reviewProvider.reviews.length +
                    (reviewProvider.isLoading || !reviewProvider.hasMoreReviews ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviewsTab(ReviewProvider reviewProvider) {
    final recentReviews = reviewProvider.recentReviews;

    return RefreshIndicator(
      onRefresh: () => reviewProvider.loadReviews(widget.lawyerId, refresh: true),
      child: recentReviews.isEmpty
          ? const Center(
              child: Text('No recent reviews'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recentReviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(recentReviews[index]);
              },
            ),
    );
  }

  Widget _buildVerifiedReviewsTab(ReviewProvider reviewProvider) {
    final verifiedReviews = reviewProvider.verifiedReviews;

    return RefreshIndicator(
      onRefresh: () => reviewProvider.loadReviews(widget.lawyerId, refresh: true),
      child: verifiedReviews.isEmpty
          ? const Center(
              child: Text('No verified reviews'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: verifiedReviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(verifiedReviews[index]);
              },
            ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isOwner = authProvider.user?.id == review.clientId;

        return ReviewCard(
          review: review,
          isOwner: isOwner,
          onEdit: isOwner ? () => _editReview(review) : null,
          onDelete: isOwner ? () => _deleteReview(review) : null,
          onMarkHelpful: (isHelpful) => _markReviewHelpful(review, isHelpful),
        );
      },
    );
  }

  void _showAddReviewDialog(AuthProvider authProvider) async {
    final user = authProvider.user;
    if (user == null) return;

    // Check if user can review this lawyer
    final reviewProvider = context.read<ReviewProvider>();
    final canReview = await reviewProvider.canClientReviewLawyer(
      clientId: user.id,
      lawyerId: widget.lawyerId,
    );

    if (!canReview) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already reviewed this lawyer'),
          ),
        );
      }
      return;
    }

    if (mounted) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddReviewScreen(
            lawyerId: widget.lawyerId,
            lawyerName: widget.lawyerName,
          ),
        ),
      );

      if (result == true) {
        _loadData(); // Refresh reviews after adding
      }
    }
  }

  void _editReview(Review review) {
    // Navigate to edit review screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          lawyerId: widget.lawyerId,
          lawyerName: widget.lawyerName,
          editingReview: review,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // Refresh reviews after editing
      }
    });
  }

  void _deleteReview(Review review) {
    final reviewProvider = context.read<ReviewProvider>();
    reviewProvider.deleteReview(review.id, widget.lawyerId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review deleted successfully'),
      ),
    );
  }

  void _markReviewHelpful(Review review, bool isHelpful) {
    final reviewProvider = context.read<ReviewProvider>();
    reviewProvider.markReviewHelpful(review.id, isHelpful);
  }
}