import 'package:flutter/material.dart';
import '../models/gig.dart';

enum SortBy {
  relevance,
  rating,
  experience,
  priceAsc,
  priceDesc,
  recent;

  String get displayName {
    switch (this) {
      case SortBy.relevance:
        return 'Relevance';
      case SortBy.rating:
        return 'Highest Rating';
      case SortBy.experience:
        return 'Most Experience';
      case SortBy.priceAsc:
        return 'Price: Low to High';
      case SortBy.priceDesc:
        return 'Price: High to Low';
      case SortBy.recent:
        return 'Recently Joined';
    }
  }
}

class LawyerSearchFilter {
  final String? searchQuery;
  final List<String> specialties;
  final String? location;
  final double? minRating;
  final RangeValues? priceRange;
  final RangeValues? experienceRange;
  final bool? isVerified;
  final bool? isAvailable;
  final SortBy sortBy;

  const LawyerSearchFilter({
    this.searchQuery,
    this.specialties = const [],
    this.location,
    this.minRating,
    this.priceRange,
    this.experienceRange,
    this.isVerified,
    this.isAvailable,
    this.sortBy = SortBy.relevance,
  });

  LawyerSearchFilter copyWith({
    String? searchQuery,
    List<String>? specialties,
    String? location,
    double? minRating,
    RangeValues? priceRange,
    RangeValues? experienceRange,
    bool? isVerified,
    bool? isAvailable,
    SortBy? sortBy,
  }) {
    return LawyerSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      specialties: specialties ?? this.specialties,
      location: location ?? this.location,
      minRating: minRating ?? this.minRating,
      priceRange: priceRange ?? this.priceRange,
      experienceRange: experienceRange ?? this.experienceRange,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return searchQuery?.isNotEmpty == true ||
        specialties.isNotEmpty ||
        location?.isNotEmpty == true ||
        minRating != null ||
        priceRange != null ||
        experienceRange != null ||
        isVerified != null ||
        isAvailable != null ||
        sortBy != SortBy.relevance;
  }

  LawyerSearchFilter clear() {
    return const LawyerSearchFilter();
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'specialties': specialties,
      'location': location,
      'minRating': minRating,
      'priceRange': priceRange != null ? {'start': priceRange!.start, 'end': priceRange!.end} : null,
      'experienceRange': experienceRange != null ? {'start': experienceRange!.start, 'end': experienceRange!.end} : null,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'sortBy': sortBy.name,
    };
  }
}

class GigSearchFilter {
  final String? searchQuery;
  final List<GigType> types;
  final String? location;
  final RangeValues? budgetRange;
  final List<String> skills;
  final bool? hasDeadline;
  final SortBy sortBy;

  const GigSearchFilter({
    this.searchQuery,
    this.types = const [],
    this.location,
    this.budgetRange,
    this.skills = const [],
    this.hasDeadline,
    this.sortBy = SortBy.recent,
  });

  GigSearchFilter copyWith({
    String? searchQuery,
    List<GigType>? types,
    String? location,
    RangeValues? budgetRange,
    List<String>? skills,
    bool? hasDeadline,
    SortBy? sortBy,
  }) {
    return GigSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      types: types ?? this.types,
      location: location ?? this.location,
      budgetRange: budgetRange ?? this.budgetRange,
      skills: skills ?? this.skills,
      hasDeadline: hasDeadline ?? this.hasDeadline,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return searchQuery?.isNotEmpty == true ||
        types.isNotEmpty ||
        location?.isNotEmpty == true ||
        budgetRange != null ||
        skills.isNotEmpty ||
        hasDeadline != null ||
        sortBy != SortBy.recent;
  }

  GigSearchFilter clear() {
    return const GigSearchFilter();
  }
}