import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../widgets/profile_avatar.dart';
import '../../chat/screens/chat_detail_screen.dart';

class ApplicantProfileView extends StatelessWidget {
  final int applicantId;
  final String? jobTitle;
  final UserModel currentUser;

  const ApplicantProfileView({
    Key? key, 
    required this.applicantId,
    this.jobTitle,
    required this.currentUser,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadViewData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final user = UserModel.fromMap(snapshot.data!['applicant']);
        final bool hasAlreadyApplied = snapshot.data!['hasApplied'] ?? false;
        final String? resolvedTitle = snapshot.data!['resolvedJobTitle'];
        final List<Map<String, dynamic>> companyJobs = List<Map<String, dynamic>>.from(snapshot.data!['jobs'] ?? []);
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resolvedTitle != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Applied for: $resolvedTitle',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (hasAlreadyApplied) ...[
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This candidate has already applied to your company.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        imagePath: user.profileImage,
                        name: user.fullName ?? user.username,
                        radius: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(user.fullName ?? user.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user.email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection('Academic Background', [
                  _buildDetail(Icons.school, user.university ?? 'N/A'),
                  _buildDetail(Icons.book, user.course ?? 'N/A'),
                  _buildDetail(Icons.grade, 'CGPA: ${user.cgpa ?? '0.00'}'),
                ]),
                const SizedBox(height: 16),
                _buildSection('Skills', [
                  Wrap(
                    spacing: 8,
                    children: (user.skills ?? '').split(',').map((s) {
                      if (s.trim().isEmpty) return const SizedBox.shrink();
                      return Chip(label: Text(s.trim()));
                    }).toList(),
                  )
                ]),
                const SizedBox(height: 16),
                _buildSection('Experience', [
                  Text(user.experience ?? 'No experience listed.', style: const TextStyle(fontSize: 14)),
                ]),
                const SizedBox(height: 32),
                
                Column(
                  children: [
                    if (!hasAlreadyApplied)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _showJobInvitationPicker(context, user, companyJobs),
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Invite to Apply'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    currentUser: currentUser,
                                    receiver: user,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message_outlined),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadViewData() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    
    final List<Map<String, dynamic>> applicantRes = await db.query('users', where: 'id = ?', whereArgs: [applicantId]);
    final List<Map<String, dynamic>> jobs = await dbHelper.getCompanyJobs(currentUser.id!);

    String? displayJobTitle = jobTitle;
    bool hasApplied = false;

    if (displayJobTitle == null) {
      final List<Map<String, dynamic>> apps = await db.rawQuery('''
        SELECT j.title 
        FROM applications a
        JOIN jobs j ON a.jobId = j.id
        WHERE a.userId = ? AND j.companyId = ?
        LIMIT 1
      ''', [applicantId, currentUser.id]);
      
      if (apps.isNotEmpty) {
        displayJobTitle = apps.first['title'];
        hasApplied = true;
      }
    } else {
      hasApplied = true;
    }

    return {
      'applicant': applicantRes.first,
      'hasApplied': hasApplied,
      'resolvedJobTitle': displayJobTitle,
      'jobs': jobs,
    };
  }

  void _showJobInvitationPicker(BuildContext context, UserModel student, List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please post a job first before inviting candidates.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Job to Invite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...jobs.map((job) => ListTile(
              leading: const Icon(Icons.work_outline, color: Colors.blue),
              title: Text(job['title']),
              onTap: () async {
                Navigator.pop(context);
                await DatabaseHelper.instance.addNotification(
                  userId: student.id!,
                  title: 'Job Invitation!',
                  message: '${currentUser.fullName} invites you to apply for their "${job['title']}" position.',
                  type: 'job',
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent successfully!'), backgroundColor: Colors.green));
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
