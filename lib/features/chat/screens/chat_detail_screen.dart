import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../widgets/profile_avatar.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel receiver;

  const ChatDetailScreen({Key? key, required this.currentUser, required this.receiver}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [widget.currentUser.id, widget.receiver.id, widget.receiver.id, widget.currentUser.id],
      orderBy: 'timestamp ASC',
    );

    if (mounted) {
      setState(() {
        _messages = maps.map((m) => ChatMessage.fromMap(m)).toList();
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      senderId: widget.currentUser.id!,
      receiverId: widget.receiver.id!,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    final db = await DatabaseHelper.instance.database;
    await db.insert('messages', newMessage.toMap());

    _messageController.clear();
    _loadMessages();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ProfileAvatar(
              imagePath: widget.receiver.profileImage,
              name: widget.receiver.fullName ?? widget.receiver.username,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.fullName ?? widget.receiver.username,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black), 
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => CallScreen(contact: widget.receiver, isVideo: true))
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black), 
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => CallScreen(contact: widget.receiver, isVideo: false))
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isMe = message.senderId == widget.currentUser.id;
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
