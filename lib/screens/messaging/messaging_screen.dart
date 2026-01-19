import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 'chat_1',
      'participantName': 'Sarah Chen',
      'participantRole': 'Corporate Lawyer',
      'participantAvatar': 'https://images.unsplash.com/photo-1594736797933-d0a9d2c95dae?auto=format&fit=crop&q=80&w=400',
      'lastMessage': 'I\'ve reviewed the contract terms and have some recommendations...',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 15)),
      'unreadCount': 2,
      'isOnline': true,
      'caseType': 'Contract Review',
    },
    {
      'id': 'chat_2',
      'participantName': 'John Martinez',
      'participantRole': 'Client',
      'participantAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      'lastMessage': 'Thank you for the update. When can we schedule the meeting?',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 0,
      'isOnline': false,
      'caseType': 'Family Law',
    },
    {
      'id': 'chat_3',
      'participantName': 'Tush Yamlash',
      'participantRole': 'Criminal Defense Lawyer',
      'participantAvatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=400',
      'lastMessage': 'The evidence analysis is complete. We should discuss next steps.',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 5)),
      'unreadCount': 1,
      'isOnline': true,
      'caseType': 'Criminal Defense',
    },
    {
      'id': 'chat_4',
      'participantName': 'Emma Thompson',
      'participantRole': 'Client',
      'participantAvatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=400',
      'lastMessage': 'Perfect! I\'ll send over the documents by tomorrow.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
      'isOnline': false,
      'caseType': 'Property Law',
    },
    {
      'id': 'chat_5',
      'participantName': 'Michael Chen',
      'participantRole': 'Immigration Lawyer',
      'participantAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=400',
      'lastMessage': 'Your visa application has been submitted successfully.',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 2)),
      'unreadCount': 0,
      'isOnline': false,
      'caseType': 'Immigration',
    },
  ];

  List<Map<String, dynamic>> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = _chats;
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Messages',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
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
                                      // Handle new chat
                                      _showNewChatDialog();
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.textPrimary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Search bar
                        TextField(
                          controller: _searchController,
                          onChanged: _filterChats,
                          decoration: InputDecoration(
                            hintText: 'Search conversations...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.borderLight,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.borderLight,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats
                if (_getUnreadCount() > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.primaryLightColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.mark_chat_unread_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You have ${_getUnreadCount()} unread messages',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Stay connected with your clients and colleagues',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Chat list
                Expanded(
                  child: _filteredChats.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = _filteredChats[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              delay: Duration(milliseconds: 200 + (index * 100)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: _buildChatCard(chat),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavBar(
            currentIndex: 2,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.home);
                  break;
                case 1:
                  context.go(isLawyer ? AppRoutes.earnings : AppRoutes.postGig);
                  break;
                case 2:
                  // Already on messaging
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

  Widget _buildChatCard(Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () => _openChat(chat),
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
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: AppTheme.borderLight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      chat['participantAvatar'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.borderLight,
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                if (chat['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['participantName'],
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat['lastMessageTime']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Role and case type
                  Row(
                    children: [
                      Text(
                        chat['participantRole'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppTheme.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        chat['caseType'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Last message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: chat['unreadCount'] > 0
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: chat['unreadCount'] > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat['unreadCount'] > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat['unreadCount'].toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with a lawyer or client',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showNewChatDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  void _filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          return chat['participantName']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              chat['lastMessage'].toLowerCase().contains(query.toLowerCase()) ||
              chat['caseType'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _openChat(Map<String, dynamic> chat) {
    context.go(
      AppRoutes.chat,
      extra: {
        'chatId': chat['id'],
        'recipientName': chat['participantName'],
      },
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start New Conversation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose who you\'d like to start a conversation with',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to lawyer search or client search
                  context.go(AppRoutes.home);
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('Browse Available Lawyers'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  int _getUnreadCount() {
    return _chats.fold(0, (sum, chat) => sum + (chat['unreadCount'] as int));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}