import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/models/user_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../widgets/profile_avatar.dart';
import '../../chat/screens/chat_detail_screen.dart';

class GraduateDetailScreen extends StatefulWidget {
  final int graduateId;
  final UserModel currentUser;
  final String? appliedJobTitle;

  const GraduateDetailScreen({
    Key? key,
    required this.graduateId,
    required this.currentUser,
    this.appliedJobTitle,
  }) : super(key: key);

  @override
  State<GraduateDetailScreen> createState() => _GraduateDetailScreenState();
}

class _GraduateDetailScreenState extends State<GraduateDetailScreen> {
  UserModel? _graduate;
  bool _isLoading = true;
  bool _hasAlreadyApplied = false;
  List<String> _appliedJobTitles = [];
  List<Map<String, dynamic>> _companyJobs = [];
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    
    final List<Map<String, dynamic>> gradRes = await db.query('users', where: 'id = ?', whereArgs: [widget.graduateId]);
    if (gradRes.isEmpty) return;
    final graduate = UserModel.fromMap(gradRes.first);

    final jobs = await dbHelper.getCompanyJobs(widget.currentUser.id!);

    final savedIds = await dbHelper.getSavedGraduateIds(widget.currentUser.id!);

    List<String> displayTitles = [];
    if (widget.appliedJobTitle != null) {
      displayTitles.add(widget.appliedJobTitle!);
    }

    final List<Map<String, dynamic>> apps = await db.rawQuery('''
      SELECT j.title 
      FROM applications a
      JOIN jobs j ON a.jobId = j.id
      WHERE a.userId = ? AND j.companyId = ? AND a.status NOT IN ('Rejected', 'Auto-Withdrawn', 'Past Job')
    ''', [widget.graduateId, widget.currentUser.id]);
    
    for (var app in apps) {
      final title = app['title'].toString();
      if (!displayTitles.contains(title)) {
        displayTitles.add(title);
      }
    }

    if (mounted) {
      setState(() {
        _graduate = graduate;
        _companyJobs = jobs;
        _isSaved = savedIds.contains(widget.graduateId);
        _appliedJobTitles = displayTitles;
        _hasAlreadyApplied = displayTitles.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    await DatabaseHelper.instance.toggleSaveGraduate(widget.currentUser.id!, widget.graduateId);
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isSaved ? 'Graduate added to shortlist' : 'Graduate removed from shortlist'), duration: const Duration(seconds: 1)),
    );
  }

  void _showJobInvitationPicker() {
    if (_companyJobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please post a job first before inviting candidates.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Job to Invite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._companyJobs.where((j) => (j['isFilled'] ?? 0) == 0).map((job) => ListTile(
              leading: const Icon(Icons.work_outline, color: Colors.blue),
              title: Text(job['title']),
              onTap: () async {
                Navigator.pop(context);
                await DatabaseHelper.instance.addNotification(
                  userId: widget.graduateId,
                  title: 'Job Invitation!',
                  message: '${widget.currentUser.fullName} invites you to apply for their "${job['title']}" position.',
                  type: 'job',
                  jobId: job['id'],
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent successfully!'), backgroundColor: Colors.green));
              },
            )).toList(),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_graduate == null) return const Scaffold(body: Center(child: Text('User not found')));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildProfileOverview(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_appliedJobTitles.isNotEmpty)
                        _buildContextBanner('Applied for: ${_appliedJobTitles.join(', ')}', Icons.assignment_turned_in, Colors.blue),
                      
                      const SizedBox(height: 16),
                      
                      _buildSectionCard(
                        title: 'Academic Background',
                        icon: Icons.school_outlined,
                        content: Column(
                          children: [
                            _buildInfoRow(Icons.account_balance, 'University', _graduate!.university ?? 'Not set'),
                            _buildInfoRow(Icons.book_outlined, 'Course', _graduate!.course ?? 'Not set'),
                            _buildInfoRow(Icons.grade_outlined, 'CGPA', '${double.tryParse(_graduate!.cgpa ?? '0.00')?.toStringAsFixed(2) ?? '0.00'} / 4.00'),
                            _buildInfoRow(Icons.history_edu, 'Level', _graduate!.educationLevel ?? 'Not set'),
                            if (_graduate!.gradYear != null)
                              _buildInfoRow(Icons.calendar_today, 'Graduation Year', _graduate!.gradYear!),
                          ],
                        ),
                      ),

                      _buildSectionCard(
                        title: 'Contact Information',
                        icon: Icons.contact_mail_outlined,
                        content: Column(
                          children: [
                            _buildInfoRow(Icons.phone_outlined, 'Phone', _graduate!.phone ?? 'Not set'),
                            _buildInfoRow(Icons.email_outlined, 'Email', _graduate!.email),
                            _buildInfoRow(Icons.cake_outlined, 'Birthday', _graduate!.dob ?? 'Not set'),
                          ],
                        ),
                      ),

                      _buildSectionCard(
                        title: 'Home Address',
                        icon: Icons.home_outlined,
                        content: _graduate!.streetAddress != null 
                          ? Text(
                              '${_graduate!.streetAddress}\n${_graduate!.postcode} ${_graduate!.city}\n${_graduate!.state}',
                              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                            )
                          : const Text('Not set', style: TextStyle(color: Colors.grey)),
                      ),

                      _buildSectionCard(
                        title: 'Core Technical Skills',
                        icon: Icons.bolt,
                        content: _graduate!.skills == null || _graduate!.skills!.isEmpty
                          ? const Text('No skills added yet.', style: TextStyle(color: Colors.grey))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _graduate!.skills!.split(',').map((skill) {
                                if (skill.trim().isEmpty) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue[100]!),
                                  ),
                                  child: Text(
                                    skill.trim(), 
                                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500)
                                  ),
                                );
                              }).toList(),
                            ),
                      ),

                      _buildSectionCard(
                        title: 'Professional Experience',
                        icon: Icons.work_history_outlined,
                        content: Text(
                          _graduate!.experience != null && _graduate!.experience!.isNotEmpty 
                            ? _graduate!.experience! 
                            : 'No experience details provided.',
                          style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      if (!_hasAlreadyApplied)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ElevatedButton.icon(
                            onPressed: _showJobInvitationPicker,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Invite to Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              currentUser: widget.currentUser,
                              receiver: _graduate!,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Message Talent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.blue,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border, 
                color: _isSaved ? Colors.blue : Colors.black,
                size: 20,
              ),
              onPressed: _toggleSave,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: _getImageProvider(_graduate!.coverImage, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: ProfileAvatar(
                imagePath: _graduate!.profileImage,
                name: _graduate!.fullName ?? _graduate!.username,
                radius: 50,
                backgroundColor: Colors.blue[400],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _graduate!.fullName ?? _graduate!.username,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                ),
                Text(
                  _graduate!.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBanner(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text('$label: ', style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: Colors.blue[400]),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}
