import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';

class MyApplicationsScreen extends StatefulWidget {
  final UserModel user;

  const MyApplicationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final db = await DatabaseHelper.instance.database;
    
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT a.id, a.status, a.timestamp, j.title as jobTitle, u.fullName as companyName, u.id as companyId
      FROM applications a
      JOIN jobs j ON a.jobId = j.id
      JOIN users u ON j.companyId = u.id
      WHERE a.userId = ?
      ORDER BY a.timestamp DESC
    ''', [widget.user.id]);

    if (mounted) {
      setState(() {
        _applications = results;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied': return Colors.blue;
      case 'Reviewing': return Colors.orange;
      case 'Interviewing': return Colors.purple;
      case 'Accepted': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? const Center(child: Text('You haven\'t applied for any jobs yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  app['jobTitle'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(app['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  app['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(app['status']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app['companyName'],
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 4),
                          Text(
                            'Applied on ${app['timestamp'].split('T')[0]}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (app['status'] == 'Accepted') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.exit_to_app, size: 18),
                                label: const Text('I have left this job', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _confirmResignation(app['id']),
                              ),
                            ),
                          ] else if (['Applied', 'Reviewing', 'Interviewing'].contains(app['status'])) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(Icons.cancel_outlined, size: 18),
                                label: const Text('Cancel Application', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red[600],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _confirmCancelApplication(
                                  app['id'], 
                                  app['companyId'], 
                                  app['jobTitle']
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmCancelApplication(int appId, int companyId, String jobTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content: Text('Are you sure you want to withdraw your application for "$jobTitle"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Application')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Withdraw', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.cancelApplication(
        applicationId: appId,
        userId: widget.user.id!,
        companyId: companyId,
        jobTitle: jobTitle,
      );
      _loadApplications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application withdrawn successfully'))
        );
      }
    }
  }

  Future<void> _confirmResignation(int appId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Resignation'),
        content: const Text('Are you sure you have left this position? This will allow you to apply for other jobs again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.resignFromJob(appId);
      _loadApplications();
    }
  }
}
