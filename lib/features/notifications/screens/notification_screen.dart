import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/models/job_model.dart';
import '../../home/screens/job_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel user;

  const NotificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [widget.user.id],
      orderBy: 'timestamp DESC',
    );

    if (mounted) {
      setState(() {
        _notifications = maps.map((m) => NotificationModel.fromMap(m)).toList();
        _isLoading = false;
      });
      
      await db.update(
        'notifications',
        {'isRead': 1},
        where: 'userId = ?',
        whereArgs: [widget.user.id],
      );
    }
  }

  Future<void> _navigateToJob(int jobId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'jobs',
      where: 'id = ?',
      whereArgs: [jobId],
    );

    if (maps.isNotEmpty && mounted) {
      final job = JobModel.fromMap(maps.first);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailScreen(job: job, currentUser: widget.user),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This job posting is no longer available.')),
      );
    }
  }

  Future<void> _clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('notifications', where: 'userId = ?', whereArgs: [widget.user.id]);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notification.isRead ? Colors.white : Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: notification.type == 'job' ? Colors.blue[100] : Colors.green[100],
                            child: Icon(
                              notification.type == 'job' ? Icons.work : Icons.person_add,
                              color: notification.type == 'job' ? Colors.blue : Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification.timestamp.split('T')[0],
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                if (notification.jobId != null) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToJob(notification.jobId!),
                                    icon: const Icon(Icons.visibility_outlined, size: 14),
                                    label: const Text('View Job Posting', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            const CircleAvatar(radius: 4, backgroundColor: Colors.red),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
