import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/models/user_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/job_model.dart';
import '../../../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'my_applications_screen.dart';
import 'manage_applications_screen.dart';
import 'my_job_postings_screen.dart';
import '../../auth/screens/first_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late UserModel _currentUser;
  List<JobModel> _jobs = [];
  int _appCount = 0;

  void refresh() {
    _refreshUserData();
  }

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_currentUser.role == 'corporate') {
      _loadJobs();
      _loadAppCount();
    } else {
      _loadAppCount();
    }
  }

  ImageProvider _getImageProvider(String? path, String defaultUrl) {
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      }
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return NetworkImage(defaultUrl);
  }

  ImageProvider? _getProfileImage(String? path) {
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      }
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  Future<void> _loadAppCount() async {
    final db = await DatabaseHelper.instance.database;
    if (_currentUser.role == 'corporate') {
      final List<Map<String, dynamic>> res = await DatabaseHelper.instance.getCompanyApplications(_currentUser.id!);
      if (mounted) {
        setState(() {
          _appCount = res.length;
        });
      }
    } else {
      final List<Map<String, dynamic>> res = await db.query(
        'applications',
        where: 'userId = ?',
        whereArgs: [_currentUser.id],
      );
      if (mounted) {
        setState(() {
          _appCount = res.length;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [_currentUser.id],
    );

    if (maps.isNotEmpty) {
      setState(() {
        _currentUser = UserModel.fromMap(maps.first);
      });
      if (_currentUser.role == 'corporate') {
        _loadJobs();
        _loadAppCount();
      } else {
        _loadAppCount();
      }
    }
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.getCompanyJobs(_currentUser.id!);
    setState(() {
      _jobs = jobs.map((m) => JobModel.fromMap(m)).toList();
    });
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteUserCompletely(_currentUser.id!);
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FirstScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FirstScreen()),
        (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isGraduate = _currentUser.role == 'graduate';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _getImageProvider(_currentUser.coverImage, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 50),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ProfileAvatar(
                      imagePath: _currentUser.profileImage,
                      name: _currentUser.fullName ?? _currentUser.username,
                      radius: 55,
                      backgroundColor: isGraduate ? Colors.blue[400] : Colors.blue[600],
                      fallbackIcon: Icons.person,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            Text(
              _currentUser.fullName ?? _currentUser.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: _currentUser),
                  ),
                );
                if (result == true) {
                  _refreshUserData();
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: Colors.blue[400]!),
              ),
              child: Text('Edit Profile', style: TextStyle(color: Colors.blue[400], fontSize: 13, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 20),

            if (isGraduate) ...[
              _buildSectionCard(
                title: 'Education Background',
                icon: Icons.school_outlined,
                content: Column(
                  children: [
                    _buildCompactInfoRow(Icons.history_edu, 'Level', _currentUser.educationLevel ?? 'Not set'),
                    _buildCompactInfoRow(Icons.account_balance, 'University', _currentUser.university ?? 'Not set'),
                    _buildCompactInfoRow(Icons.book_outlined, 'Course', _currentUser.course ?? 'Not set'),
                    _buildCompactInfoRow(Icons.grade_outlined, 'CGPA', '${double.tryParse(_currentUser.cgpa ?? '0.00')?.toStringAsFixed(2) ?? '0.00'} / 4.00'),
                    _buildCompactInfoRow(Icons.cake_outlined, 'Birthday', _currentUser.dob ?? 'Not set'),
                  ],
                ),
              ),

              _buildSectionCard(
                title: 'Application Status',
                icon: Icons.assignment_turned_in_outlined,
                content: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyApplicationsScreen(user: _currentUser))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                              child: Text('$_appCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                            const SizedBox(width: 12),
                            const Text('Jobs Applied', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              _buildSectionCard(
                title: 'Business Overview',
                icon: Icons.business,
                content: Column(
                  children: [
                    _buildCompactInfoRow(Icons.local_offer_outlined, 'Industry', _currentUser.industry ?? 'Not set'),
                    _buildCompactInfoRow(Icons.access_time, 'Working Hours', _currentUser.workingHours ?? 'Not set'),
                    _buildCompactInfoRow(
                      Icons.location_on_outlined, 
                      'Base Location', 
                      (_currentUser.location != null && _currentUser.location!.isNotEmpty) 
                        ? _currentUser.location! 
                        : (_currentUser.city != null ? '${_currentUser.city}, ${_currentUser.state}' : 'Not set')
                    ),
                  ],
                ),
              ),

              _buildSectionCard(
                title: 'Manage Applications',
                icon: Icons.assignment_outlined,
                content: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ManageApplicationsScreen(company: _currentUser))
                    );
                    _refreshUserData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                              child: Text('$_appCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                            const SizedBox(width: 12),
                            const Text('Applications Received', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            if (isGraduate) ...[
              _buildSectionCard(
                title: 'Core Technical Skills',
                icon: Icons.bolt,
                content: _currentUser.skills == null || _currentUser.skills!.isEmpty
                  ? const Text('No skills added yet.', style: TextStyle(color: Colors.grey))
                  : Wrap(
                      spacing: 8,
                      children: _currentUser.skills!.split(',').map((skill) {
                        if (skill.trim().isEmpty) return const SizedBox.shrink();
                        return Chip(
                          label: Text(skill.trim(), style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue[50],
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
              ),

              _buildSectionCard(
                title: 'Professional Experience',
                icon: Icons.work_history_outlined,
                content: Text(
                  _currentUser.experience != null && _currentUser.experience!.isNotEmpty 
                    ? _currentUser.experience! 
                    : 'No experience details provided.',
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                ),
              ),
            ] else ...[
              _buildSectionCard(
                title: 'Company Detail',
                icon: Icons.info_outline,
                content: Text(
                  _currentUser.companyDetail ?? 'No company detail added yet.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
              
              _buildSectionCard(
                title: 'Job Management',
                icon: Icons.list_alt_rounded,
                content: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => MyJobPostingsScreen(company: _currentUser))
                    );
                    _loadJobs();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                              child: Text('${_jobs.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                            const SizedBox(width: 12),
                            const Text('Job Postings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            _buildSectionCard(
              title: 'Contact & Address',
              icon: Icons.contact_mail_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(Icons.phone_outlined, _currentUser.phone ?? 'No phone'),
                  _buildContactItem(Icons.email_outlined, _currentUser.email),
                  if (_currentUser.streetAddress != null) ...[
                    const Divider(height: 24),
                    Text(
                      isGraduate ? 'Full Home Address' : 'Full Office Address',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentUser.streetAddress}\n${_currentUser.postcode} ${_currentUser.city}\n${_currentUser.state}',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Account Settings'),
            const SizedBox(height: 8),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.blue),
                    title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: _logout,
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: _deleteAccount,
                    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.red),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue[400]),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
