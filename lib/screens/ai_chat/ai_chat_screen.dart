import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../core/theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'ai_welcome',
      'content': 'Hello! I\'m your AI legal assistant. I can help you with legal questions, document reviews, case research, and more. How can I assist you today?',
      'isFromAi': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
    },
  ];

  final List<String> _suggestedQuestions = [
    'What are the key elements of a valid contract?',
    'How do I file a small claims case?',
    'What should I know about intellectual property?',
    'Explain the difference between civil and criminal law',
    'What are my rights as a tenant?',
    'How do I start a business legally?',
  ];

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
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryDarkColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
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
                    'AI Legal Assistant',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isTyping ? 'Thinking...' : 'Online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isTyping
                          ? AppTheme.primaryColor
                          : AppTheme.successColor,
                      fontStyle: _isTyping ? FontStyle.italic : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This AI assistant provides general legal information only. Always consult with a qualified lawyer for specific legal advice.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildMessageBubble(message),
                  ),
                );
              },
            ),
          ),

          // Suggested questions (show when no user messages)
          if (_messages.length == 1) _buildSuggestedQuestions(),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything about law...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDarkColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _isTyping ? null : _sendMessage,
                      icon: Icon(
                        _isTyping ? Icons.stop_rounded : Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isFromAi = message['isFromAi'] ?? false;

    return Row(
      mainAxisAlignment: isFromAi ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isFromAi) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryDarkColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isFromAi
                  ? AppTheme.surfaceColor
                  : AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isFromAi
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
                bottomRight: isFromAi
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
              ),
              border: isFromAi
                  ? Border.all(
                      color: AppTheme.borderLight,
                      width: 1,
                    )
                  : null,
            ),
            child: Text(
              message['content'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isFromAi ? AppTheme.textPrimary : Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ),
        if (!isFromAi) const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryDarkColor,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 4),
              _buildDot(1),
              const SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Questions',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return GestureDetector(
                onTap: () => _sendSuggestedQuestion(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({
        'id': 'm${_messages.length}',
        'content': text,
        'isFromAi': false,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
    _scrollToBottom();
    _simulateAiResponse(text);
  }

  void _sendSuggestedQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _simulateAiResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });

    // Simulate AI thinking time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': 'ai_${_messages.length}',
            'content': _generateAiResponse(userMessage),
            'isFromAi': true,
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    });
  }

  String _generateAiResponse(String userMessage) {
    // Simple AI response simulation based on keywords
    final message = userMessage.toLowerCase();

    if (message.contains('contract')) {
      return 'A valid contract typically requires: (1) Offer, (2) Acceptance, (3) Consideration, (4) Mutual assent, and (5) Capacity to contract. Both parties must be legally able to enter into the agreement, and the terms must be clear and definite.';
    } else if (message.contains('small claims')) {
      return 'To file a small claims case: (1) Determine if your case qualifies (usually disputes under \$5,000-\$10,000), (2) Try to resolve the matter first, (3) File your claim at the local courthouse, (4) Pay the filing fee, (5) Serve the defendant, and (6) Prepare for your court date.';
    } else if (message.contains('intellectual property') || message.contains('ip')) {
      return 'Intellectual property includes: Patents (inventions), Trademarks (brand names/logos), Copyrights (creative works), and Trade secrets (confidential business info). Each has different protection periods and requirements.';
    } else if (message.contains('civil') && message.contains('criminal')) {
      return 'Civil law deals with disputes between private parties (contracts, torts, family matters) where the remedy is usually monetary damages. Criminal law involves prosecution by the government for violations of criminal statutes, with potential penalties including fines and imprisonment.';
    } else if (message.contains('tenant') || message.contains('rent')) {
      return 'As a tenant, you generally have rights to: (1) Habitable living conditions, (2) Privacy (proper notice for entry), (3) Protection from discrimination, (4) Return of security deposit, and (5) Protection from retaliatory eviction. Rights vary by state and local laws.';
    } else if (message.contains('business') || message.contains('company')) {
      return 'To start a business legally: (1) Choose a business structure (LLC, Corporation, etc.), (2) Register your business name, (3) Obtain necessary licenses and permits, (4) Get an EIN from the IRS, (5) Open a business bank account, and (6) Consider business insurance.';
    } else {
      return 'That\'s an interesting legal question. While I can provide general information, I\'d recommend consulting with a qualified attorney for specific advice about your situation. Legal matters can be complex and fact-specific.';
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'id': 'ai_welcome',
        'content': 'Hello! I\'m your AI legal assistant. I can help you with legal questions, document reviews, case research, and more. How can I assist you today?',
        'isFromAi': true,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}