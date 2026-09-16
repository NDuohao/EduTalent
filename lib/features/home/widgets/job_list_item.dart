import 'package:flutter/material.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../widgets/profile_avatar.dart';
import '../screens/job_detail_screen.dart';

class JobListItem extends StatefulWidget {
  final JobModel job;
  final UserModel currentUser;
  final bool savedStatus;
  final VoidCallback onToggle;
  final VoidCallback onRefresh;

  const JobListItem({
    Key? key,
    required this.job,
    required this.currentUser,
    required this.savedStatus,
    required this.onToggle,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<JobListItem> createState() => _JobListItemState();
}

class _JobListItemState extends State<JobListItem> {
  UserModel? _company;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final db = await DatabaseHelper.instance.database;
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(job: widget.job, currentUser: widget.currentUser),
          ),
        ).then((_) => widget.onRefresh());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              imagePath: _company?.profileImage,
              name: _company?.fullName ?? _company?.username,
              radius: 25,
              fallbackIcon: Icons.business,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.job.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          widget.savedStatus ? Icons.bookmark : Icons.bookmark_border,
                          size: 22,
                          color: widget.savedStatus ? Colors.blue : Colors.grey,
                        ),
                        onPressed: widget.onToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_company?.fullName ?? '...'} • ${_company?.industry ?? 'General'}',
                    style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(widget.job.category, Colors.orange[50]!, Colors.orange[800]!),
                      _buildTag(widget.job.jobType, Colors.green[50]!, Colors.green[800]!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoIcon(Icons.location_on_outlined, widget.job.location),
                      const SizedBox(width: 16),
                      _buildInfoIcon(Icons.payments_outlined, widget.job.salaryRange ?? 'TBD'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoIcon(Icons.access_time, widget.job.workingHours ?? 'Flexible'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.job.skills != null && widget.job.skills!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.job.skills!.split(',').map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(s.trim(), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      )).toList(),
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailScreen(job: widget.job, currentUser: widget.currentUser),
                          ),
                        ).then((_) => widget.onRefresh());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
