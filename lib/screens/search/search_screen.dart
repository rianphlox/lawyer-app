import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../core/constants.dart';
import '../../models/lawyer.dart';
import '../../models/gig.dart';
import '../../models/search_filter.dart';
import '../../services/search_service.dart';
import '../../widgets/lawyer_card.dart';
import '../../widgets/gig_card.dart';

class SearchScreen extends StatefulWidget {
  final bool isSearchingGigs;

  const SearchScreen({
    super.key,
    this.isSearchingGigs = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  LawyerSearchFilter _lawyerFilter = const LawyerSearchFilter();
  GigSearchFilter _gigFilter = const GigSearchFilter();

  List<Lawyer> _filteredLawyers = [];
  List<Gig> _filteredGigs = [];
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isSearchingGigs ? 1 : 0,
    );

    _filteredLawyers = MockData.mockLawyers;
    _filteredGigs = MockData.mockGigs;

    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.textPrimary,
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppTheme.borderLight,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onTap: () {
              setState(() {
                _showSuggestions = true;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search lawyers or gigs...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppTheme.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.textPrimary,
                ),
                if (_hasActiveFilters())
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Lawyers'),
            Tab(text: 'Gigs'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Active filters
              if (_hasActiveFilters()) _buildActiveFilters(),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLawyersTab(),
                    _buildGigsTab(),
                  ],
                ),
              ),
            ],
          ),

          // Search suggestions overlay
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            _buildSuggestionsOverlay(),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildFilterChips(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    if (_tabController.index == 0) {
      // Lawyer filters
      if (_lawyerFilter.specialties.isNotEmpty) {
        chips.addAll(_lawyerFilter.specialties.map((specialty) =>
            _buildFilterChip(specialty, () {
              setState(() {
                _lawyerFilter = _lawyerFilter.copyWith(
                  specialties: _lawyerFilter.specialties.where((s) => s != specialty).toList(),
                );
                _applyFilters();
              });
            })));
      }

      if (_lawyerFilter.minRating != null) {
        chips.add(_buildFilterChip(
          '${_lawyerFilter.minRating!.toStringAsFixed(1)}+ stars',
          () {
            setState(() {
              _lawyerFilter = _lawyerFilter.copyWith(minRating: null);
              _applyFilters();
            });
          },
        ));
      }

      if (_lawyerFilter.isVerified == true) {
        chips.add(_buildFilterChip(
          'Verified Only',
          () {
            setState(() {
              _lawyerFilter = _lawyerFilter.copyWith(isVerified: null);
              _applyFilters();
            });
          },
        ));
      }
    } else {
      // Gig filters
      if (_gigFilter.types.isNotEmpty) {
        chips.addAll(_gigFilter.types.map((type) =>
            _buildFilterChip(type.displayName, () {
              setState(() {
                _gigFilter = _gigFilter.copyWith(
                  types: _gigFilter.types.where((t) => t != type).toList(),
                );
                _applyFilters();
              });
            })));
      }

      if (_gigFilter.budgetRange != null) {
        chips.add(_buildFilterChip(
          '\$${_gigFilter.budgetRange!.start.toInt()}-\$${_gigFilter.budgetRange!.end.toInt()}',
          () {
            setState(() {
              _gigFilter = _gigFilter.copyWith(budgetRange: null);
              _applyFilters();
            });
          },
        ));
      }
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close_rounded, size: 18),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      side: BorderSide(
        color: AppTheme.primaryColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  Widget _buildLawyersTab() {
    if (_filteredLawyers.isEmpty) {
      return _buildEmptyState('No lawyers found', 'Try adjusting your search or filters');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _filteredLawyers[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 50),
          child: LawyerCard(
            lawyer: lawyer,
            onTap: () => context.go(
              AppRoutes.lawyerDetails,
              extra: lawyer,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGigsTab() {
    if (_filteredGigs.isEmpty) {
      return _buildEmptyState('No gigs found', 'Try adjusting your search or filters');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGigs.length,
      itemBuilder: (context, index) {
        final gig = _filteredGigs[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 50),
          child: GigCard(
            gig: gig,
            onTap: () => context.go(
              AppRoutes.gigDetails,
              extra: gig,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent searches
            if (SearchService.getRecentSearches().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              ...SearchService.getRecentSearches().map((search) =>
                  _buildSuggestionItem(search, Icons.history_rounded)),
              const Divider(),
            ],

            // Search suggestions
            if (_searchSuggestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Suggestions',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              ..._searchSuggestions.map((suggestion) =>
                  _buildSuggestionItem(suggestion, Icons.search_rounded)),
            ],

            // Popular searches
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Popular Searches',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ...SearchService.getPopularSearchTerms().take(3).map((search) =>
                _buildSuggestionItem(search, Icons.trending_up_rounded)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: AppTheme.textSecondary,
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        _searchController.text = text;
        setState(() {
          _showSuggestions = false;
        });
        _onSearchChanged();
      },
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
        _resetFilters();
      });
      return;
    }

    // Update search filters
    if (_tabController.index == 0) {
      _lawyerFilter = _lawyerFilter.copyWith(searchQuery: query);
      _searchSuggestions = SearchService.getLawyerSearchSuggestions(
        query,
        MockData.mockLawyers,
      );
    } else {
      _gigFilter = _gigFilter.copyWith(searchQuery: query);
      _searchSuggestions = SearchService.getGigSearchSuggestions(
        query,
        MockData.mockGigs,
      );
    }

    setState(() {
      _showSuggestions = query.isNotEmpty && _searchSuggestions.isNotEmpty;
    });

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredLawyers = SearchService.searchLawyers(
        MockData.mockLawyers,
        _lawyerFilter,
      );
      _filteredGigs = SearchService.searchGigs(
        MockData.mockGigs,
        _gigFilter,
      );
    });
  }

  void _resetFilters() {
    setState(() {
      _filteredLawyers = MockData.mockLawyers;
      _filteredGigs = MockData.mockGigs;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _lawyerFilter = LawyerSearchFilter(searchQuery: _lawyerFilter.searchQuery);
      _gigFilter = GigSearchFilter(searchQuery: _gigFilter.searchQuery);
    });
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return _lawyerFilter.hasActiveFilters || _gigFilter.hasActiveFilters;
  }

  void _showFilterBottomSheet() {
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

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _clearAllFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _tabController.index == 0
                      ? _buildLawyerFilters()
                      : _buildGigFilters(),
                ),
              ),

              // Apply button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLawyerFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Specialties
        Text(
          'Specialties',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.legalSpecialties.map((specialty) {
            final isSelected = _lawyerFilter.specialties.contains(specialty);
            return FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _lawyerFilter = _lawyerFilter.copyWith(
                      specialties: [..._lawyerFilter.specialties, specialty],
                    );
                  } else {
                    _lawyerFilter = _lawyerFilter.copyWith(
                      specialties: _lawyerFilter.specialties
                          .where((s) => s != specialty)
                          .toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Rating
        Text(
          'Minimum Rating',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: _lawyerFilter.minRating ?? 0.0,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: _lawyerFilter.minRating?.toStringAsFixed(1) ?? '0.0',
          onChanged: (value) {
            setState(() {
              _lawyerFilter = _lawyerFilter.copyWith(
                minRating: value > 0 ? value : null,
              );
            });
          },
        ),

        const SizedBox(height: 24),

        // Verification
        CheckboxListTile(
          title: const Text('Verified Lawyers Only'),
          value: _lawyerFilter.isVerified ?? false,
          onChanged: (value) {
            setState(() {
              _lawyerFilter = _lawyerFilter.copyWith(
                isVerified: value == true ? true : null,
              );
            });
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildGigFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gig Types
        Text(
          'Gig Types',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GigType.values.map((type) {
            final isSelected = _gigFilter.types.contains(type);
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _gigFilter = _gigFilter.copyWith(
                      types: [..._gigFilter.types, type],
                    );
                  } else {
                    _gigFilter = _gigFilter.copyWith(
                      types: _gigFilter.types.where((t) => t != type).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}