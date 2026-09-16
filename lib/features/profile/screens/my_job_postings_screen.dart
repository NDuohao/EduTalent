import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/job_model.dart';
import 'add_job_screen.dart';

class MyJobPostingsScreen extends StatefulWidget {
  final UserModel company;

  const MyJobPostingsScreen({Key? key, required this.company}) : super(key: key);

  @override
  State<MyJobPostingsScreen> createState() => _MyJobPostingsScreenState();
}

class _MyJobPostingsScreenState extends State<MyJobPostingsScreen> {
  List<JobModel> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.getCompanyJobs(widget.company.id!);
    if (mounted) {
      setState(() {
        _jobs = jobs.map((m) => JobModel.fromMap(m)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeJobs = _jobs.where((j) => !j.isFilled).toList();
    final closedJobs = _jobs.where((j) => j.isFilled).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: const Text('My Job Postings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddJobScreen(company: widget.company),
                        ),
                      );
                      if (result == true) _loadJobs();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Upload New Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Active Vacancies (${activeJobs.length})'),
                  const SizedBox(height: 12),
                  if (activeJobs.isEmpty)
                    _buildEmptyState('No active vacancies.')
                  else
                    ...activeJobs.map((job) => _buildJobCard(job)),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Filled / Closed History (${closedJobs.length})'),
                  const SizedBox(height: 12),
                  if (closedJobs.isEmpty)
                    _buildEmptyState('No closed jobs yet.')
                  else
                    ...closedJobs.map((job) => _buildJobCard(job, isFilled: true)),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ),
    );
  }

  Widget _buildJobCard(JobModel job, {bool isFilled = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFilled ? Colors.green[100]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isFilled ? Colors.green[50] : Colors.blue[50], 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(isFilled ? Icons.check_circle_outline : Icons.work_outline, color: isFilled ? Colors.green : Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        job.title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      )
                    ),
                    if (isFilled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                        child: const Text('FILLED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  job.location, 
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isFilled)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddJobScreen(company: widget.company, job: job)),
                );
                if (result == true) _loadJobs();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(job),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(JobModel job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Are you sure you want to delete "${job.title}"? This will also remove all associated applications.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteJob(job.id!);
      _loadJobs();
    }
  }
}
