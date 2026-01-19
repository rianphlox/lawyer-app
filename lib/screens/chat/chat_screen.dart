import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/theme.dart';
import '../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecipientOnline = true;
  bool _isTyping = false;

  // Mock messages data
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'm1',
      'senderId': 'user1',
      'senderName': 'You',
      'content': 'Hi Sarah, I\'ve reviewed the initial contract draft. There are a few clauses I\'d like to discuss.',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
      'isFromMe': true,
    },
    {
      'id': 'm2',
      'senderId': 'user2',
      'senderName': 'Sarah Chen',
      'content': 'Good morning! I\'d be happy to go through those clauses with you. Which sections specifically caught your attention?',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      'isRead': true,
      'isFromMe': false,
    },
    {
      'id': 'm3',
      'senderId': 'user1',
      'senderName': 'You',
      'content': 'Mainly sections 4.2 and 7.1 regarding intellectual property rights and termination clauses.',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      'isRead': true,
      'isFromMe': true,
    },
    {
      'id': 'm4',
      'senderId': 'user2',
      'senderName': 'Sarah Chen',
      'content': 'Perfect. Those are indeed critical sections. I have some amendments I can suggest. Let me send you a marked-up version.',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
      'isRead': true,
      'isFromMe': false,
    },
    {
      'id': 'm5',
      'senderId': 'user2',
      'senderName': 'Sarah Chen',
      'content': 'Contract_Review_v2.pdf',
      'type': MessageType.file,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      'isRead': true,
      'isFromMe': false,
      'fileName': 'Contract_Review_v2.pdf',
      'fileSize': 245760, // 240KB
    },
    {
      'id': 'm6',
      'senderId': 'user1',
      'senderName': 'You',
      'content': 'Thank you! I\'ll review this and get back to you with any questions by tomorrow.',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': true,
      'isFromMe': true,
    },
    {
      'id': 'm7',
      'senderId': 'user2',
      'senderName': 'Sarah Chen',
      'content': 'Sounds good! Also, I wanted to mention that based on the contract complexity, my estimated timeline for completion would be 3-5 business days. Does that work for your schedule?',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
      'isFromMe': false,
    },
    {
      'id': 'm8',
      'senderId': 'user2',
      'senderName': 'Sarah Chen',
      'content': 'I\'ve also prepared a brief summary of the key changes I\'m recommending.',
      'type': MessageType.text,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      'isRead': false,
      'isFromMe': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate typing indicator
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
            });
          }
        });
      }
    });
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
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.borderLight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1594736797933-d0a9d2c95dae?auto=format&fit=crop&q=80&w=400',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (_isRecipientOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(6),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isTyping
                        ? 'typing...'
                        : _isRecipientOnline
                            ? 'Online'
                            : 'Last seen 2h ago',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isTyping
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
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
            onPressed: _showChatOptions,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
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

          // Message input
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
                  // Attachment button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _showAttachmentOptions,
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Message input field
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
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // Handle typing indicator
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
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
    final bool isFromMe = message['isFromMe'];
    final MessageType type = message['type'];

    return Row(
      mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isFromMe) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.borderLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1594736797933-d0a9d2c95dae?auto=format&fit=crop&q=80&w=400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isFromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isFromMe
                      ? AppTheme.primaryColor
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isFromMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isFromMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                  border: isFromMe
                      ? null
                      : Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                ),
                child: type == MessageType.file
                    ? _buildFileMessage(message, isFromMe)
                    : _buildTextMessage(message, isFromMe),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTime(message['timestamp']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  if (isFromMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message['isRead']
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 12,
                      color: message['isRead']
                          ? AppTheme.primaryColor
                          : AppTheme.textTertiary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (isFromMe) const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isFromMe) {
    return Text(
      message['content'],
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isFromMe ? Colors.white : AppTheme.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildFileMessage(Map<String, dynamic> message, bool isFromMe) {
    final String fileName = message['fileName'] ?? 'Unknown file';
    final int fileSize = message['fileSize'] ?? 0;
    final String fileSizeString = _formatFileSize(fileSize);

    return GestureDetector(
      onTap: () => _handleFileDownload(message),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isFromMe ? Colors.white : AppTheme.primaryColor)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: isFromMe ? Colors.white : AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isFromMe ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSizeString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (isFromMe ? Colors.white : AppTheme.textSecondary)
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.borderLight,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1594736797933-d0a9d2c95dae?auto=format&fit=crop&q=80&w=400',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ),
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
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'id': 'm${_messages.length + 1}',
        'senderId': 'user1',
        'senderName': 'You',
        'content': text,
        'type': MessageType.text,
        'timestamp': DateTime.now(),
        'isRead': false,
        'isFromMe': true,
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _showAttachmentOptions() {
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
              'Send Attachment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  'Document',
                  Icons.description_outlined,
                  AppTheme.primaryColor,
                  () => _pickFile(),
                ),
                _buildAttachmentOption(
                  'Photo',
                  Icons.image_outlined,
                  AppTheme.successColor,
                  () => _pickImage(),
                ),
                _buildAttachmentOption(
                  'Camera',
                  Icons.camera_alt_outlined,
                  AppTheme.warningColor,
                  () => _takePhoto(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
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
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                _startVideoCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                _startVoiceCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _blockUser();
              },
            ),
          ],
        ),
      ),
    );
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _messages.add({
            'id': 'm${_messages.length + 1}',
            'senderId': 'user1',
            'senderName': 'You',
            'content': file.name,
            'type': MessageType.file,
            'timestamp': DateTime.now(),
            'isRead': false,
            'isFromMe': true,
            'fileName': file.name,
            'fileSize': file.size,
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker not implemented in this demo'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera not implemented in this demo'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting video call...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting voice call...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${widget.recipientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.recipientName} has been blocked'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _handleFileDownload(Map<String, dynamic> message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${message['fileName']}...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}