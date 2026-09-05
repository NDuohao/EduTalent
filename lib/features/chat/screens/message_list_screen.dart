import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../widgets/profile_avatar.dart';
import 'chat_detail_screen.dart';

class MessageListScreen extends StatefulWidget {
  final UserModel currentUser;

  const MessageListScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<MessageListScreen> createState() => MessageListScreenState();
}

class MessageListScreenState extends State<MessageListScreen> {
  List<UserModel> _contacts = [];
  List<UserModel> _filteredContacts = [];
  Map<int, Map<String, dynamic>> _lastMessages = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  void refresh() {
    _loadContacts();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = (contact.fullName ?? contact.username).toLowerCase();
        return name.contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  Future<void> _loadContacts() async {
    final db = await DatabaseHelper.instance.database;
    final otherRole = widget.currentUser.role == 'graduate' ? 'corporate' : 'graduate';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [otherRole],
    );

    List<UserModel> allContacts = maps.map((m) => UserModel.fromMap(m)).toList();
    List<UserModel> activeContacts = [];
    Map<int, Map<String, dynamic>> lastMsgs = {};

    for (var contact in allContacts) {
      final lastMsg = await DatabaseHelper.instance.getLastMessage(widget.currentUser.id!, contact.id!);
      if (lastMsg != null) {
        lastMsgs[contact.id!] = lastMsg;
        activeContacts.add(contact);
      }
    }

    if (mounted) {
      setState(() {
        _contacts = activeContacts;
        _lastMessages = lastMsgs;
        _filteredContacts = _contacts;
        _isLoading = false;
      });
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                ProfileAvatar(
                  imagePath: widget.currentUser.profileImage,
                  name: widget.currentUser.fullName ?? widget.currentUser.username,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search message',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? const Center(child: Text('No matches found'))
                    : ListView.separated(
                        itemCount: _filteredContacts.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final lastMsg = _lastMessages[contact.id];
                          
                          return ListTile(
                            leading: ProfileAvatar(
                              imagePath: contact.profileImage,
                              name: contact.fullName ?? contact.username,
                              radius: 24,
                            ),
                            title: Text(contact.fullName ?? contact.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              lastMsg?['content'] ?? 'No messages yet',
                              style: TextStyle(
                                color: lastMsg == null ? Colors.grey[400] : Colors.grey,
                                fontStyle: lastMsg == null ? FontStyle.italic : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatTime(lastMsg?['timestamp']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    currentUser: widget.currentUser,
                                    receiver: contact,
                                  ),
                                ),
                              ).then((_) => _loadContacts());
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
