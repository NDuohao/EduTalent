import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/job_model.dart';
import '../../../core/services/open_data_service.dart';
import '../../../core/utils/filter_logic.dart';
import '../widgets/job_list_item.dart';
import 'industrial_hubs_screen.dart';
import 'saved_jobs_screen.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../../widgets/profile_avatar.dart';

class GraduateHomeScreen extends StatefulWidget {
  final UserModel user;
  final Function(int)? onSwitchTab;

  const GraduateHomeScreen({Key? key, required this.user, this.onSwitchTab}) : super(key: key);

  @override
  State<GraduateHomeScreen> createState() => GraduateHomeScreenState();
}

class GraduateHomeScreenState extends State<GraduateHomeScreen> {
  List<JobModel> _allJobs = [];
  List<JobModel> _filteredJobs = [];
  List<int> _savedJobIds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  void refresh() {
    _loadInitialData();
  }

  String _selectedCategory = 'All';
  String _selectedJobType = 'All';
  bool _sortByNearby = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> maps = await dbHelper.getAllJobsWithCompany();
      final savedIds = await dbHelper.getSavedJobIds(widget.user.id!);
      
      if (mounted) {
        setState(() {
          _allJobs = maps.map((m) => JobModel.fromMap(m)).toList();
          _filteredJobs = _allJobs;
          _savedJobIds = savedIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final matchesSearch = query.isEmpty || 
                 job.title.toLowerCase().contains(query) || 
                 job.location.toLowerCase().contains(query) || 
                 (job.skills ?? '').toLowerCase().contains(query) ||
                 (job.companyName ?? '').toLowerCase().contains(query) ||
                 job.category.toLowerCase().contains(query) ||
                 job.jobType.toLowerCase().contains(query);

        bool matchesCategory = _selectedCategory == 'All';
        if (!matchesCategory) {
          final filter = _selectedCategory.toLowerCase().replaceAll('&', ' ');
          final category = job.category.toLowerCase().replaceAll('&', ' ');
          final filterWords = filter.split(' ').where((w) => w.trim().length >= 2 && w.trim() != 'and').toList();
          
          matchesCategory = category.contains(filter) || filter.contains(category) || 
                            filterWords.any((word) => category.contains(word.trim()));
        }

        bool matchesJobType = _selectedJobType == 'All';
        if (!matchesJobType) {
          final filter = _selectedJobType.toLowerCase();
          final type = job.jobType.toLowerCase();
          matchesJobType = type.contains(filter) || filter.contains(type);
        }

        bool matchesState = true;
        if (_sortByNearby && widget.user.state != null && widget.user.state!.isNotEmpty) {
          matchesState = job.location.toLowerCase().contains(widget.user.state!.toLowerCase());
        }

        return matchesSearch && matchesCategory && matchesJobType && matchesState;
      }).toList();

      if (_sortByNearby) {
        _filteredJobs.sort((a, b) {
          final distA = FilterLogic.calculateDistance(
            startLat: widget.user.latitude,
            startLng: widget.user.longitude,
            endLat: a.latitude,
            endLng: a.longitude,
          );
          final distB = FilterLogic.calculateDistance(
            startLat: widget.user.latitude,
            startLng: widget.user.longitude,
            endLat: b.latitude,
            endLng: b.longitude,
          );
          return distA.compareTo(distB);
        });
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Nearby (My State Only)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Only show jobs in your current state'),
                  value: _sortByNearby,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    setState(() => _sortByNearby = val);
                    setModalState(() => _sortByNearby = val);
                  },
                ),
                const Divider(),
                const Text('Job Category', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: FilterLogic.getJobCategories().map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                            setModalState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Job Type', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: FilterLogic.getJobTypes().map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: _selectedJobType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedJobType = type);
                            setModalState(() => _selectedJobType = type);
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshSavedState() async {
    final updatedIds = await DatabaseHelper.instance.getSavedJobIds(widget.user.id!);
    setState(() {
      _savedJobIds = updatedIds;
    });
  }

  Future<void> _toggleSave(int jobId) async {
    await DatabaseHelper.instance.toggleSaveJob(widget.user.id!, jobId);
    _refreshSavedState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildHubDiscoveryBanner(context),
              const SizedBox(height: 32),
              _buildSearchBar(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Career Opportunities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              _buildJobList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Text(
                  widget.user.fullName ?? widget.user.username, 
                  style: const TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              NotificationBell(user: widget.user),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.bookmark_outline, size: 28),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => SavedJobsScreen(currentUser: widget.user))
                ).then((_) => _loadInitialData()),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.onSwitchTab?.call(3),
                child: ProfileAvatar(imagePath: widget.user.profileImage, radius: 24, name: widget.user.fullName ?? widget.user.username),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHubDiscoveryBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IndustrialHubsScreen(currentUser: widget.user))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Corporate Map Discovery', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Discover top companies registered in your area', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.map_outlined, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search jobs, locations, or skills...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: (_selectedCategory != 'All' || _selectedJobType != 'All' || _sortByNearby) ? Colors.blue : Colors.grey),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    if (_filteredJobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Looking for matches...', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return JobListItem(
          job: job,
          currentUser: widget.user,
          savedStatus: _savedJobIds.contains(job.id),
          onToggle: () => _toggleSave(job.id!),
          onRefresh: _refreshSavedState,
        );
      },
    );
  }
}
