import '../models/lawyer.dart';
import '../models/gig.dart';

class AppConstants {
  static const String appName = 'LegalLink';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String lawyersCollection = 'lawyers';
  static const String gigsCollection = 'gigs';
  static const String applicationsCollection = 'applications';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String paymentsCollection = 'payments';
  static const String reviewsCollection = 'reviews';

  // Shared Preferences Keys
  static const String userRoleKey = 'user_role';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeModeKey = 'theme_mode';

  // Legal Specialties
  static const List<String> legalSpecialties = [
    'Crime Lawyers',
    'Family Lawyers',
    'Business',
    'Immigration',
    'Property',
    'Intellectual Property',
    'Corporate',
    'Tax Law',
    'Employment',
    'Personal Injury',
  ];

  // Default placeholder images
  static const String defaultProfileImage = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=400';
  static const String defaultLawyerImage = 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=400';
}

// Mock Data for Development
class MockData {
  static final List<Lawyer> mockLawyers = [
    Lawyer(
      id: 'l1',
      name: 'Tush Yamlash',
      specialty: 'Crime Lawyer',
      location: 'New York City',
      rating: 4.9,
      casesWon: 320,
      pricePerHour: 250.0,
      experienceYears: 12,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      about: 'Tush Yamlash is a highly skilled criminal defense lawyer known for her strong courtroom presence and strategic approach. With over a decade of experience in criminal law, she has successfully represented clients in complex cases.',
      isVerified: true,
      certifications: ['Criminal Defense Specialist', 'Trial Advocacy Certificate'],
      specializations: ['Criminal Defense', 'DUI Defense', 'White Collar Crime'],
    ),
    Lawyer(
      id: 'l2',
      name: 'Robert Adler',
      specialty: 'Family Lawyer',
      location: 'Chicago, IL',
      rating: 4.8,
      casesWon: 410,
      pricePerHour: 180.0,
      experienceYears: 15,
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=400',
      about: 'Robert specializes in high-stakes family law disputes, focusing on mediation and positive resolution for all parties involved.',
      isVerified: true,
      certifications: ['Family Law Specialist', 'Mediation Certificate'],
      specializations: ['Divorce', 'Child Custody', 'Family Mediation'],
    ),
    Lawyer(
      id: 'l3',
      name: 'Sarah Chen',
      specialty: 'Corporate Lawyer',
      location: 'San Francisco, CA',
      rating: 5.0,
      casesWon: 150,
      pricePerHour: 350.0,
      experienceYears: 8,
      imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0a9d2c95dae?auto=format&fit=crop&q=80&w=400',
      about: 'Sarah provides top-tier corporate legal advice for tech startups and Fortune 500 companies alike.',
      isVerified: true,
      certifications: ['Corporate Law Specialist', 'Securities Law Certificate'],
      specializations: ['Corporate Law', 'M&A', 'Securities'],
    ),
  ];

  static final List<Gig> mockGigs = [
    Gig(
      id: 'g1',
      title: 'Intellectual Property Dispute',
      description: 'Need assistance with a copyright infringement case involving software source code. Looking for an experienced IP lawyer.',
      budget: 5000.0,
      clientName: 'TechNova Solutions',
      clientId: 'c1',
      type: GigType.intellectual,
      status: GigStatus.open,
      postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      deadline: DateTime.now().add(const Duration(days: 30)),
      requiredSkills: ['IP Law', 'Software', 'Litigation'],
    ),
    Gig(
      id: 'g2',
      title: 'DUI Defense Case',
      description: 'Looking for a junior lawyer to handle initial court appearances for a simple DUI charge.',
      budget: 1200.0,
      clientName: 'John Doe',
      clientId: 'c2',
      type: GigType.crime,
      status: GigStatus.open,
      postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      deadline: DateTime.now().add(const Duration(days: 14)),
      requiredSkills: ['Criminal Defense', 'DUI'],
    ),
    Gig(
      id: 'g3',
      title: 'Real Estate Contract Review',
      description: 'Reviewing a purchase agreement for a commercial property in Manhattan.',
      budget: 2500.0,
      clientName: 'Skyline Props',
      clientId: 'c3',
      type: GigType.property,
      status: GigStatus.open,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      deadline: DateTime.now().add(const Duration(days: 7)),
      requiredSkills: ['Real Estate', 'Contract Review'],
    ),
  ];
}