import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../widgets/graduate_list_item.dart';

class SavedTalentsScreen extends StatefulWidget {
  final UserModel currentUser;

  const SavedTalentsScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<SavedTalentsScreen> createState() => _SavedTalentsScreenState();
}

class _SavedTalentsScreenState extends State<SavedTalentsScreen> {
  List<UserModel> _savedTalents = [];
  List<int> _appliedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper.instance;
    final results = await dbHelper.getSavedGraduates(widget.currentUser.id!);
    final appliedIds = await dbHelper.getAppliedStudentIds(widget.currentUser.id!);
    
    if (mounted) {
      setState(() {
        _savedTalents = results.map((m) => UserModel.fromMap(m)).toList();
        _appliedIds = appliedIds;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Talents', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedTalents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your shortlist is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _savedTalents.length,
                  itemBuilder: (context, index) {
                    final graduate = _savedTalents[index];
                    return GraduateListItem(
                      graduate: graduate,
                      currentUser: widget.currentUser,
                      isSaved: true,
                      isApplicant: _appliedIds.contains(graduate.id),
                      onSaveToggle: () async {
                        await DatabaseHelper.instance.toggleSaveGraduate(
                          widget.currentUser.id!,
                          graduate.id!,
                        );
                        _loadData();
                      },
                    );
                  },
                ),
    );
  }
}
