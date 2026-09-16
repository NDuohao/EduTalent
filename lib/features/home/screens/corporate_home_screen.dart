import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/filter_logic.dart';
import '../widgets/graduate_list_item.dart';
import '../../notifications/widgets/notification_bell.dart';
import 'saved_talents_screen.dart';
import '../../../widgets/profile_avatar.dart';

class CorporateHomeScreen extends StatefulWidget {
  final UserModel user;
  final Function(int)? onSwitchTab;

  const CorporateHomeScreen({
    Key? key, 
    required this.user, 
    this.onSwitchTab
  }) : super(key: key);

  @override
  State<CorporateHomeScreen> createState() => CorporateHomeScreenState();
}

class CorporateHomeScreenState extends State<CorporateHomeScreen> {
  List<UserModel> _allGraduates = [];
  List<UserModel> _filteredGraduates = [];
  List<int> _savedIds = [];
  List<int> _appliedIds = [];
  
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  void refresh() {
    _loadInitialData();
  }

  String _selectedCourse = 'All';
  String _selectedEduLevel = 'All';
  bool _sortByNearby = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      
      final List<Map<String, dynamic>> maps = await dbHelper.getGraduatesForCorporate();
      final savedIds = await dbHelper.getSavedGraduateIds(widget.user.id!);
      final appliedIds = await dbHelper.getAppliedStudentIds(widget.user.id!);

      if (mounted) {
        setState(() {
          _allGraduates = maps.map((m) => UserModel.fromMap(m)).toList();
          _filteredGraduates = _allGraduates;
          _savedIds = savedIds;
          _appliedIds = appliedIds;
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
      _filteredGraduates = _allGraduates.where((g) {
        final matchesSearch = query.isEmpty || 
                 (g.fullName ?? g.username).toLowerCase().contains(query) || 
                 (g.university ?? '').toLowerCase().contains(query) || 
                 (g.skills ?? '').toLowerCase().contains(query) ||
                 (g.course ?? '').toLowerCase().contains(query) ||
                 (g.state ?? '').toLowerCase().contains(query) ||
                 (g.educationLevel ?? '').toLowerCase().contains(query);

        bool matchesCourse = _selectedCourse == 'All';
        if (!matchesCourse) {
          final filter = _selectedCourse.toLowerCase().replaceAll('&', ' ');
          final course = (g.course ?? '').toLowerCase().replaceAll('&', ' ');
          final filterWords = filter.split(' ').where((w) => w.trim().length >= 2 && w.trim() != 'and').toList();
          
          matchesCourse = course.contains(filter) || filter.contains(course) ||
                         filterWords.any((word) => course.contains(word.trim()));
        }

        bool matchesEdu = _selectedEduLevel == 'All';
        if (!matchesEdu) {
          final filter = _selectedEduLevel.toLowerCase();
          final edu = (g.educationLevel ?? '').toLowerCase();
          matchesEdu = edu.contains(filter) || filter.contains(edu);
        }

        bool matchesState = true;
        if (_sortByNearby && widget.user.state != null && widget.user.state!.isNotEmpty) {
          matchesState = (g.state ?? '').toLowerCase().contains(widget.user.state!.toLowerCase());
        }

        return matchesSearch && matchesCourse && matchesEdu && matchesState;
      }).toList();

      if (_sortByNearby) {
        _filteredGraduates.sort((a, b) {
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
                const Text('Filter Talents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                SwitchListTile(
                  title: const Text('Nearby (My State Only)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Only show graduates in your state'),
                  value: _sortByNearby,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    setState(() => _sortByNearby = val);
                    setModalState(() => _sortByNearby = val);
                  },
                ),
                const Divider(),
  
                const Text('Course / Field of Study', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: FilterLogic.getCourses().map((course) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(course),
                        selected: _selectedCourse == course,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCourse = course);
                            setModalState(() => _selectedCourse = course);
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
  
                const Text('Education Level', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: FilterLogic.getEducationLevels().map((level) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(level),
                        selected: _selectedEduLevel == level,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedEduLevel = level);
                            setModalState(() => _selectedEduLevel = level);
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

  Future<void> _toggleSave(int graduateId) async {
    await DatabaseHelper.instance.toggleSaveGraduate(widget.user.id!, graduateId);
    final updatedSavedIds = await DatabaseHelper.instance.getSavedGraduateIds(widget.user.id!);
    setState(() {
      _savedIds = updatedSavedIds;
    });
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
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Text('Best Matches', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              ),
              _buildGradList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    Text(
                      widget.user.fullName ?? widget.user.username, 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue),
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
                      MaterialPageRoute(builder: (context) => SavedTalentsScreen(currentUser: widget.user))
                    ).then((_) => _loadInitialData()),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onSwitchTab?.call(3),
                    child: ProfileAvatar(imagePath: widget.user.profileImage, radius: 22, name: widget.user.fullName ?? widget.user.username),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Search skills or graduates...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.blue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune, 
              color: (_selectedCourse != 'All' || _selectedEduLevel != 'All' || _sortByNearby) ? Colors.blue : Colors.blueGrey
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ),
      ],
    );
  }

  Widget _buildGradList() {
    return _filteredGraduates.isEmpty
      ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No graduates match your search.')))
      : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredGraduates.length,
          itemBuilder: (context, index) {
            final graduate = _filteredGraduates[index];
            return GraduateListItem(
              graduate: graduate,
              currentUser: widget.user,
              isSaved: _savedIds.contains(graduate.id),
              isApplicant: _appliedIds.contains(graduate.id),
              onSaveToggle: () => _toggleSave(graduate.id!),
              onRefresh: _loadInitialData,
            );
          },
        );
  }
}
