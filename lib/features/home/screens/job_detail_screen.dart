import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../../../core/models/job_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../widgets/profile_avatar.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  final UserModel currentUser;

  const JobDetailScreen({Key? key, required this.job, required this.currentUser}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  UserModel? _company;
  bool _isApplied = false;
  bool _isSaved = false;
  bool _isCurrentlyEmployed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.job.companyId],
    );
    if (maps.isNotEmpty && mounted) {
      setState(() {
        _company = UserModel.fromMap(maps.first);
      });
    }

    final List<Map<String, dynamic>> apps = await db.query(
      'applications',
      where: 'jobId = ? AND userId = ?',
      whereArgs: [widget.job.id, widget.currentUser.id],
    );
    
    final savedIds = await dbHelper.getSavedJobIds(widget.currentUser.id!);

    final isEmployed = await dbHelper.isUserCurrentlyEmployed(widget.currentUser.id!);

    if (mounted) {
      setState(() {
        _isApplied = apps.isNotEmpty;
        _isSaved = savedIds.contains(widget.job.id);
        _isCurrentlyEmployed = isEmployed;
      });
    }
  }

  Future<void> _toggleSave() async {
    await DatabaseHelper.instance.toggleSaveJob(widget.currentUser.id!, widget.job.id!);
    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'Job saved to shortlist' : 'Job removed from shortlist'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _applyForJob() async {
    if (_isApplied) return;

    final db = await DatabaseHelper.instance.database;
    await db.insert('applications', {
      'jobId': widget.job.id,
      'userId': widget.currentUser.id,
      'status': 'Applied',
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() {
        _isApplied = true;
      });
      
      await DatabaseHelper.instance.database.then((db) => db.insert('messages', {
        'senderId': widget.currentUser.id,
        'receiverId': widget.job.companyId,
        'content': 'Hello! I have just applied for your "${widget.job.title}" position. Looking forward to hearing from you.',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': 0,
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double lat = widget.job.latitude ?? _company?.latitude ?? 3.1472;
    double lng = widget.job.longitude ?? _company?.longitude ?? 101.6995;
    LatLng position = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildJobHeader(),
                  const SizedBox(height: 24),
                  
                  _buildSectionCard(
                    title: 'Job Overview',
                    content: Column(
                      children: [
                        _buildIconText(Icons.category_outlined, 'Category', widget.job.category),
                        _buildIconText(Icons.work_outline, 'Job Type', widget.job.jobType),
                        _buildIconText(Icons.payments_outlined, 'Salary', widget.job.salaryRange ?? 'RM 4,500 - RM 6,000 / Month'),
                        _buildIconText(Icons.access_time, 'Working Hours', widget.job.workingHours ?? '9:00 AM - 6:00 PM (Mon - Fri)'),
                        _buildIconText(Icons.location_on_outlined, 'Location', widget.job.location),
                      ],
                    ),
                  ),

                  _buildSectionCard(
                    title: 'Company Detail',
                    content: Text(
                      _company?.companyDetail ?? 'No company details available.',
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ),

                  _buildSectionCard(
                    title: 'Required Skills',
                    content: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.job.skills ?? '').split(',').map((skill) {
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
                    title: 'Job Description',
                    content: Text(
                      widget.job.description ?? 'No description provided.',
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Work Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: position,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.edutalent.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: position,
                                width: 80,
                                height: 80,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isApplied || _isCurrentlyEmployed) ? null : _applyForJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isApplied || _isCurrentlyEmployed) ? Colors.grey : Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isCurrentlyEmployed 
                          ? 'Employed Elsewhere' 
                          : (_isApplied ? 'Already Applied' : 'Apply Now'), 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  if (_isCurrentlyEmployed)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Center(
                        child: Text(
                          'You must leave your current job before applying for new ones.',
                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
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
          backgroundColor: Colors.white.withOpacity(0.9),
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
            backgroundColor: Colors.white.withOpacity(0.9),
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
            _company?.coverImage != null
                ? Image(
                    image: _getImageProvider(_company!.coverImage!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.business, size: 80, color: Colors.white24)),
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

  Widget _buildJobHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.translate(
          offset: const Offset(0, -10),
          child: ProfileAvatar(
            imagePath: _company?.profileImage,
            name: _company?.fullName ?? _company?.username,
            radius: 45,
            backgroundColor: Colors.white,
            fallbackIcon: Icons.business,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.job.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                '${_company?.fullName ?? '...'} • ${_company?.industry ?? 'General'}',
                style: const TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop');
  }

  Widget _buildIconText(IconData icon, String label, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                Text(
                  text, 
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
