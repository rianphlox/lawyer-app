import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/landing/landing_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/lawyer_details/lawyer_details_screen.dart';
import '../screens/gig_details/gig_details_screen.dart';
import '../screens/post_gig/post_gig_screen.dart';
import '../screens/messaging/messaging_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/applications/applications_screen.dart';
import '../screens/verification/verification_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/legal/legal_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../models/lawyer.dart';
import '../models/gig.dart';

class AppRoutes {
  static const String landing = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String lawyerDetails = '/lawyer-details';
  static const String gigDetails = '/gig-details';
  static const String postGig = '/post-gig';
  static const String messaging = '/messaging';
  static const String chat = '/chat';
  static const String earnings = '/earnings';
  static const String applications = '/applications';
  static const String verification = '/verification';
  static const String aiChat = '/ai-chat';
  static const String settings = '/settings';
  static const String legal = '/legal';
  static const String payments = '/payments';

  static final GoRouter router = GoRouter(
    initialLocation: landing,
    routes: [
      GoRoute(
        path: landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: lawyerDetails,
        builder: (context, state) {
          final lawyer = state.extra as Lawyer;
          return LawyerDetailsScreen(lawyer: lawyer);
        },
      ),
      GoRoute(
        path: gigDetails,
        builder: (context, state) {
          final gig = state.extra as Gig;
          return GigDetailsScreen(gig: gig);
        },
      ),
      GoRoute(
        path: postGig,
        builder: (context, state) => const PostGigScreen(),
      ),
      GoRoute(
        path: messaging,
        builder: (context, state) => const MessagingScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ChatScreen(
            chatId: args['chatId'],
            recipientName: args['recipientName'],
          );
        },
      ),
      GoRoute(
        path: earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: applications,
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: verification,
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: legal,
        builder: (context, state) => const LegalScreen(),
      ),
      GoRoute(
        path: payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
    ],
  );
}