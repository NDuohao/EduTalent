import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/job_model.dart';
import '../widgets/job_list_item.dart';

class SavedJobsScreen extends StatefulWidget {
  final UserModel currentUser;

  const SavedJobsScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  List<JobModel> _savedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    final results = await DatabaseHelper.instance.getSavedJobs(widget.currentUser.id!);
    if (mounted) {
      setState(() {
        _savedJobs = results.map((m) => JobModel.fromMap(m)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedJobs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your saved jobs list is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _savedJobs.length,
                  itemBuilder: (context, index) {
                    return JobListItem(
                      job: _savedJobs[index],
                      currentUser: widget.currentUser,
                      savedStatus: true,
                      onToggle: () async {
                        await DatabaseHelper.instance.toggleSaveJob(
                          widget.currentUser.id!,
                          _savedJobs[index].id!,
                        );
                        _loadSavedJobs();
                      },
                      onRefresh: _loadSavedJobs,
                    );
                  },
                ),
    );
  }
}
