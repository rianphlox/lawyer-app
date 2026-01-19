import '../models/lawyer.dart';
import '../models/gig.dart';
import '../models/search_filter.dart';
import '../core/constants.dart';

class SearchService {
  // Search lawyers with filters
  static List<Lawyer> searchLawyers(
    List<Lawyer> lawyers,
    LawyerSearchFilter filter,
  ) {
    List<Lawyer> result = List.from(lawyers);

    // Apply search query filter
    if (filter.searchQuery?.isNotEmpty == true) {
      final query = filter.searchQuery!.toLowerCase();
      result = result.where((lawyer) {
        return lawyer.name.toLowerCase().contains(query) ||
            lawyer.specialty.toLowerCase().contains(query) ||
            lawyer.about.toLowerCase().contains(query) ||
            lawyer.specializations.any((spec) => spec.toLowerCase().contains(query));
      }).toList();
    }

    // Apply specialty filter
    if (filter.specialties.isNotEmpty) {
      result = result.where((lawyer) {
        return filter.specialties.any((specialty) =>
            lawyer.specialty.contains(specialty) ||
            lawyer.specializations.contains(specialty));
      }).toList();
    }

    // Apply location filter
    if (filter.location?.isNotEmpty == true) {
      final location = filter.location!.toLowerCase();
      result = result.where((lawyer) {
        return lawyer.location.toLowerCase().contains(location);
      }).toList();
    }

    // Apply rating filter
    if (filter.minRating != null) {
      result = result.where((lawyer) {
        return lawyer.rating >= filter.minRating!;
      }).toList();
    }

    // Apply price range filter
    if (filter.priceRange != null) {
      result = result.where((lawyer) {
        return lawyer.pricePerHour >= filter.priceRange!.start &&
            lawyer.pricePerHour <= filter.priceRange!.end;
      }).toList();
    }

    // Apply experience range filter
    if (filter.experienceRange != null) {
      result = result.where((lawyer) {
        return lawyer.experienceYears >= filter.experienceRange!.start &&
            lawyer.experienceYears <= filter.experienceRange!.end;
      }).toList();
    }

    // Apply verification filter
    if (filter.isVerified != null) {
      result = result.where((lawyer) {
        return lawyer.isVerified == filter.isVerified!;
      }).toList();
    }

    // Apply sorting
    result = _sortLawyers(result, filter.sortBy);

    return result;
  }

  // Search gigs with filters
  static List<Gig> searchGigs(
    List<Gig> gigs,
    GigSearchFilter filter,
  ) {
    List<Gig> result = List.from(gigs);

    // Apply search query filter
    if (filter.searchQuery?.isNotEmpty == true) {
      final query = filter.searchQuery!.toLowerCase();
      result = result.where((gig) {
        return gig.title.toLowerCase().contains(query) ||
            gig.description.toLowerCase().contains(query) ||
            gig.clientName.toLowerCase().contains(query) ||
            gig.requiredSkills.any((skill) => skill.toLowerCase().contains(query));
      }).toList();
    }

    // Apply type filter
    if (filter.types.isNotEmpty) {
      result = result.where((gig) {
        return filter.types.contains(gig.type);
      }).toList();
    }

    // Apply budget range filter
    if (filter.budgetRange != null) {
      result = result.where((gig) {
        return gig.budget >= filter.budgetRange!.start &&
            gig.budget <= filter.budgetRange!.end;
      }).toList();
    }

    // Apply skills filter
    if (filter.skills.isNotEmpty) {
      result = result.where((gig) {
        return filter.skills.any((skill) =>
            gig.requiredSkills.any((gigSkill) =>
                gigSkill.toLowerCase().contains(skill.toLowerCase())));
      }).toList();
    }

    // Apply deadline filter
    if (filter.hasDeadline != null) {
      result = result.where((gig) {
        return (gig.deadline != null) == filter.hasDeadline!;
      }).toList();
    }

    // Apply sorting
    result = _sortGigs(result, filter.sortBy);

    return result;
  }

  // Get search suggestions for lawyers
  static List<String> getLawyerSearchSuggestions(String query, List<Lawyer> lawyers) {
    if (query.isEmpty) return [];

    final suggestions = <String>{};
    final queryLower = query.toLowerCase();

    // Add matching lawyer names
    for (final lawyer in lawyers) {
      if (lawyer.name.toLowerCase().contains(queryLower)) {
        suggestions.add(lawyer.name);
      }

      // Add matching specialties
      if (lawyer.specialty.toLowerCase().contains(queryLower)) {
        suggestions.add(lawyer.specialty);
      }

      // Add matching specializations
      for (final spec in lawyer.specializations) {
        if (spec.toLowerCase().contains(queryLower)) {
          suggestions.add(spec);
        }
      }

      // Add matching locations
      if (lawyer.location.toLowerCase().contains(queryLower)) {
        suggestions.add(lawyer.location);
      }
    }

    // Add matching predefined specialties
    for (final specialty in AppConstants.legalSpecialties) {
      if (specialty.toLowerCase().contains(queryLower)) {
        suggestions.add(specialty);
      }
    }

    return suggestions.take(5).toList();
  }

  // Get search suggestions for gigs
  static List<String> getGigSearchSuggestions(String query, List<Gig> gigs) {
    if (query.isEmpty) return [];

    final suggestions = <String>{};
    final queryLower = query.toLowerCase();

    // Add matching gig titles
    for (final gig in gigs) {
      if (gig.title.toLowerCase().contains(queryLower)) {
        suggestions.add(gig.title);
      }

      // Add matching skills
      for (final skill in gig.requiredSkills) {
        if (skill.toLowerCase().contains(queryLower)) {
          suggestions.add(skill);
        }
      }
    }

    return suggestions.take(5).toList();
  }

  // Sort lawyers
  static List<Lawyer> _sortLawyers(List<Lawyer> lawyers, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.rating:
        return lawyers..sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.experience:
        return lawyers..sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
      case SortBy.priceAsc:
        return lawyers..sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      case SortBy.priceDesc:
        return lawyers..sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
      case SortBy.recent:
        return lawyers; // Would need createdAt field
      case SortBy.relevance:
      default:
        return lawyers;
    }
  }

  // Sort gigs
  static List<Gig> _sortGigs(List<Gig> gigs, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.recent:
        return gigs..sort((a, b) => b.postedAt.compareTo(a.postedAt));
      case SortBy.priceDesc:
        return gigs..sort((a, b) => b.budget.compareTo(a.budget));
      case SortBy.priceAsc:
        return gigs..sort((a, b) => a.budget.compareTo(b.budget));
      case SortBy.rating:
        return gigs; // Gigs don't have ratings
      case SortBy.experience:
        return gigs; // Gigs don't have experience
      case SortBy.relevance:
        return gigs;
    }
  }

  // Get popular search terms
  static List<String> getPopularSearchTerms() {
    return [
      'Contract Review',
      'Family Law',
      'Criminal Defense',
      'Corporate Law',
      'Immigration',
      'Intellectual Property',
      'Real Estate',
      'Personal Injury',
      'Employment Law',
      'Tax Law',
    ];
  }

  // Get recent search history (in a real app, this would be stored locally)
  static List<String> getRecentSearches() {
    return [
      'Criminal defense lawyer',
      'Contract review',
      'Family law mediation',
      'IP attorney',
    ];
  }
}