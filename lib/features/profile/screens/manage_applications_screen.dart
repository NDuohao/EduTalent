import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../home/screens/graduate_detail_screen.dart';

class ManageApplicationsScreen extends StatefulWidget {
  final UserModel company;

  const ManageApplicationsScreen({Key? key, required this.company}) : super(key: key);

  @override
  State<ManageApplicationsScreen> createState() => _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final results = await DatabaseHelper.instance.getCompanyApplications(widget.company.id!);
    if (mounted) {
      setState(() {
        _applications = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int appId, int studentId, String jobTitle, String newStatus) async {
    await DatabaseHelper.instance.updateApplicationStatus(appId, newStatus);
    
    await DatabaseHelper.instance.addNotification(
      userId: studentId,
      title: 'Application Status Updated',
      message: 'Your application for "$jobTitle" at ${widget.company.fullName} is now: $newStatus',
      type: 'job',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      _loadApplications();
    }
  }

  void _showStatusPicker(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Applied', 'Reviewing', 'Interviewing', 'Accepted', 'Rejected'].map((status) {
          return ListTile(
            title: Text(status, style: TextStyle(
              color: status == 'Accepted' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.black87),
              fontWeight: FontWeight.w600,
            )),
            onTap: () async {
              if (status == 'Accepted') {
                final confirm = await _showConfirmHireDialog(app['jobTitle'], app['applicantName']);
                if (confirm == true && mounted) {
                  Navigator.pop(context);
                  _updateStatus(app['id'], app['applicantId'], app['jobTitle'], status);
                }
              } else if (status == 'Rejected') {
                final confirm = await _showConfirmRejectDialog(app['jobTitle'], app['applicantName']);
                if (confirm == true && mounted) {
                  Navigator.pop(context);
                  _updateStatus(app['id'], app['applicantId'], app['jobTitle'], status);
                }
              } else {
                Navigator.pop(context);
                _updateStatus(app['id'], app['applicantId'], app['jobTitle'], status);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<bool?> _showConfirmHireDialog(String jobTitle, String applicantName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Hire'),
        content: Text(
          'Are you sure you want to hire $applicantName for the "$jobTitle" position?\n\n'
          'Once confirmed:\n'
          '• This job will be marked as FILLED.\n'
          '• It will be removed from public search.\n'
          '• ALL other applicants for this job will be automatically rejected.'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Confirm Hire', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmRejectDialog(String jobTitle, String applicantName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: Text('Are you sure you want to reject $applicantName for the "$jobTitle" position? This candidate will be notified.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _applications.where((app) => 
      ['Applied', 'Reviewing', 'Interviewing'].contains(app['status'])
    ).toList();
    
    final history = _applications.where((app) => 
      ['Accepted', 'Rejected', 'Auto-Withdrawn', 'Rejected (Job Filled)', 'Past Job'].contains(app['status'])
    ).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFD),
        appBar: AppBar(
          title: const Text('Manage Applications', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAppList(pending, isHistory: false),
                  _buildAppList(history, isHistory: true),
                ],
              ),
      ),
    );
  }

  Widget _buildAppList(List<Map<String, dynamic>> apps, {required bool isHistory}) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isHistory ? Icons.history_rounded : Icons.assignment_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isHistory ? 'No decision history yet.' : 'No pending applications.',
              style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraduateDetailScreen(
                    graduateId: app['applicantId'],
                    currentUser: widget.company,
                    appliedJobTitle: app['jobTitle'],
                  ),
                ),
              ).then((_) => _loadApplications());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          app['applicantName'] ?? 'Anonymous',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      if (!isHistory)
                        ActionChip(
                          label: Text(app['status']),
                          onPressed: () => _showStatusPicker(app),
                          backgroundColor: Colors.blue[50],
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(app['status']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            app['status'],
                            style: TextStyle(
                              color: _getStatusColor(app['status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.work_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Position: ${app['jobTitle']}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Applied ${app['timestamp'].split('T')[0]}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Rejected': 
      case 'Rejected (Job Filled)': return Colors.red;
      case 'Auto-Withdrawn': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
