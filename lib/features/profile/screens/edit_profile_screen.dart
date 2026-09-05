import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;
import '../../../app/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../widgets/skill_tag_input.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _universityController;
  late TextEditingController _courseController;
  late TextEditingController _cgpaController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late List<String> _skillList;
  late TextEditingController _experienceController;

  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _postcodeController;
  String? _selectedState;
  final List<String> _malaysiaStates = [
    'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan', 'Pahang', 
    'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak', 'Selangor', 
    'Terengganu', 'W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya'
  ];

  String? _selectedEducationLevel;
  final List<String> _educationLevels = ['Diploma', 'Degree', 'Master', 'PhD', 'Other'];

  late TextEditingController _industryController;
  late TextEditingController _locationController;
  late TextEditingController _companyDetailController;
  
  String? _selectedWorkingDays;
  String? _selectedStartTime;
  String? _selectedEndTime;

  final List<String> _workingDayOptions = [
    'Monday - Friday', 'Monday - Saturday', 'Monday - Sunday', 'Flexible Days', 'Shift-based'
  ];
  
  final List<String> _timeSlots = [
    '07:00 AM', '07:30 AM', '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
    '07:00 PM', '07:30 PM', '08:00 PM', '08:30 PM', '09:00 PM', '09:30 PM', '10:00 PM'
  ];
  
  double? _selectedLat;
  double? _selectedLng;

  String? _profileImagePath;
  String? _coverImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _universityController = TextEditingController(text: widget.user.university);
    _courseController = TextEditingController(text: widget.user.course);
    _cgpaController = TextEditingController(text: widget.user.cgpa);
    _dobController = TextEditingController(text: widget.user.dob);
    _phoneController = TextEditingController(text: widget.user.phone);
    _skillList = widget.user.skills != null && widget.user.skills!.isNotEmpty
        ? widget.user.skills!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : [];
    _experienceController = TextEditingController(text: widget.user.experience);
    
    _streetController = TextEditingController(text: widget.user.streetAddress);
    _cityController = TextEditingController(text: widget.user.city);
    _postcodeController = TextEditingController(text: widget.user.postcode);
    _selectedState = widget.user.state;

    _selectedEducationLevel = widget.user.educationLevel;

    _industryController = TextEditingController(text: widget.user.industry);
    _locationController = TextEditingController(text: widget.user.location);
    _companyDetailController = TextEditingController(text: widget.user.companyDetail);
    
    if (widget.user.workingHours != null && widget.user.workingHours!.contains(', ')) {
      final parts = widget.user.workingHours!.split(', ');
      _selectedWorkingDays = parts[0];
      if (parts[1].contains(' - ')) {
        final times = parts[1].split(' - ');
        _selectedStartTime = times[0];
        _selectedEndTime = times[1];
      }
    }

    _selectedLat = widget.user.latitude;
    _selectedLng = widget.user.longitude;
    _profileImagePath = widget.user.profileImage;
    _coverImagePath = widget.user.coverImage;
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    _cgpaController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _companyDetailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime initial = DateTime(2000);
    if (_dobController.text.isNotEmpty) {
      try {
        final parts = _dobController.text.split('/');
        initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } catch(_) {}
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked != null) {
      setState(() {
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        _dobController.text = "$day/$month/${picked.year}";
      });
    }
  }

  Future<String?> _saveImageLocally(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path_pkg.extension(image.path)}';
    final savedPath = path_pkg.join(directory.path, fileName);
    final File newImage = await File(image.path).copy(savedPath);
    return newImage.path;
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final String? savedPath = await _saveImageLocally(image);
      setState(() {
        if (isProfile) {
          _profileImagePath = savedPath;
        } else {
          _coverImagePath = savedPath;
        }
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Profile Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              title: const Text('Change Profile Picture', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.image, color: Colors.white)),
              title: const Text('Change Background Image', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Update Office Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_selectedLat ?? 3.1472, _selectedLng ?? 101.6995),
                    initialZoom: 13,
                    onTap: (tapPosition, point) {
                      setModalState(() {
                        _selectedLat = point.latitude;
                        _selectedLng = point.longitude;
                      });
                      setState(() {
                        _selectedLat = point.latitude;
                        _selectedLng = point.longitude;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.edutalent.app',
                    ),
                    if (_selectedLat != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_selectedLat!, _selectedLng!),
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;
    
    final cgpaValue = double.tryParse(_cgpaController.text) ?? 0.0;
    final formattedCgpa = cgpaValue.toStringAsFixed(2);

    final updatedUser = UserModel(
      id: widget.user.id,
      username: widget.user.username,
      fullName: _fullNameController.text,
      email: widget.user.email,
      password: widget.user.password,
      role: widget.user.role,
      university: widget.user.role == 'graduate' ? _universityController.text : null,
      course: widget.user.role == 'graduate' ? _courseController.text : null,
      cgpa: widget.user.role == 'graduate' ? formattedCgpa : null,
      educationLevel: widget.user.role == 'graduate' ? _selectedEducationLevel : null,
      industry: widget.user.role == 'corporate' ? _industryController.text : null,
      location: widget.user.role == 'corporate' ? _locationController.text : null,
      workingHours: widget.user.role == 'corporate' 
          ? "$_selectedWorkingDays, $_selectedStartTime - $_selectedEndTime" 
          : null,
      companyDetail: widget.user.role == 'corporate' ? _companyDetailController.text : null,
      bio: widget.user.bio,
      gradYear: widget.user.gradYear,
      phone: _phoneController.text,
      skills: _skillList.map((s) => s.trim().toUpperCase()).join(','),
      experience: _experienceController.text,
      dob: widget.user.role == 'graduate' ? _dobController.text : null,
      streetAddress: _streetController.text,
      city: _cityController.text,
      state: _selectedState,
      postcode: _postcodeController.text,
      latitude: _selectedLat,
      longitude: _selectedLng,
      profileImage: _profileImagePath,
      coverImage: _coverImagePath,
      isProfileComplete: true,
    );

    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [widget.user.id],
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGraduate = widget.user.role == 'graduate';
    final primaryColor = isGraduate ? AppColors.graduatePrimary : AppColors.corporatePrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: _getImageProvider(_coverImagePath, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showImagePickerOptions,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: isGraduate ? Colors.blue[400] : Colors.blue[600],
                                    backgroundImage: _getProfileImage(_profileImagePath),
                                    child: (_profileImagePath == null || _profileImagePath!.isEmpty)
                                        ? const Icon(Icons.person, size: 60, color: Colors.black)
                                        : null,
                                  ),
                                ),
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.edit, size: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                _buildSectionTitle(isGraduate ? 'Personal Information' : 'Company Information'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _fullNameController, 
                  hintText: isGraduate ? 'Full Name' : 'Company Name', 
                  prefixIcon: Icons.person,
                  validator: (val) => val!.isEmpty ? 'Field is required' : null,
                ),
                const SizedBox(height: 12),
                if (isGraduate) ...[
                  _buildLabel('Date of Birth'),
                  CustomTextField(
                    controller: _dobController,
                    hintText: 'Tap to select',
                    prefixIcon: Icons.cake_outlined,
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.blue),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (val) => val!.isEmpty ? 'Birthday is required' : null,
                  ),
                ],
                const SizedBox(height: 30),
                
                if (isGraduate) ...[
                  _buildSectionTitle('Academic Information'),
                  const SizedBox(height: 16),
                  _buildLabel('Education Level'),
                  DropdownButtonFormField<String>(
                    value: _selectedEducationLevel,
                    isExpanded: true,
                    decoration: _getInputDecoration('Select level', Icons.school_outlined),
                    items: _educationLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (val) => setState(() => _selectedEducationLevel = val),
                    validator: (val) => val == null ? 'Level is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _universityController, 
                    hintText: 'University', 
                    prefixIcon: Icons.account_balance,
                    validator: (val) => val!.isEmpty ? 'University is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _courseController, 
                    hintText: 'Course', 
                    prefixIcon: Icons.book,
                    validator: (val) => val!.isEmpty ? 'Course is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _cgpaController, 
                    hintText: 'CGPA', 
                    prefixIcon: Icons.grade, 
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'CGPA is required';
                      final num = double.tryParse(val);
                      if (num == null) return 'Enter a valid number';
                      if (num < 2.0 || num > 4.0) return 'Must be between 2.00 - 4.00';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle('Professional Details'),
                  const SizedBox(height: 16),
                  _buildLabel('Core Technical Skills'),
                  SkillTagInput(
                    initialSkills: _skillList,
                    onChanged: (newList) => _skillList = newList,
                    hintText: 'Add a skill (e.g. Flutter, Java)...',
                  ),
                  const SizedBox(height: 12),
                  _buildMultiLineField(_experienceController, 'Describe your experience...'),
                ] else ...[
                  _buildSectionTitle('Business Details'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _industryController, 
                    hintText: 'Industry', 
                    prefixIcon: Icons.category,
                    validator: (val) => val!.isEmpty ? 'Industry is required' : null,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  _buildLabel('Working Schedule'),
                  DropdownButtonFormField<String>(
                    value: _selectedWorkingDays,
                    isExpanded: true,
                    decoration: _getInputDecoration('Select days', Icons.calendar_month),
                    items: _workingDayOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => _selectedWorkingDays = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Working Hours'),
                  DropdownButtonFormField<String>(
                    value: _selectedStartTime,
                    isExpanded: true,
                    decoration: _getInputDecoration('Start Time', Icons.access_time),
                    items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedStartTime = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('End Time'),
                  DropdownButtonFormField<String>(
                    value: _selectedEndTime,
                    isExpanded: true,
                    decoration: _getInputDecoration('End Time', Icons.access_time_filled),
                    items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedEndTime = val),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (_selectedStartTime != null) {
                        final start = _parseTime(_selectedStartTime!);
                        final end = _parseTime(val);
                        if (start != null && end != null) {
                          final startMins = start.hour * 60 + start.minute;
                          final endMins = end.hour * 60 + end.minute;
                          if (startMins >= endMins) return 'Must be after Start';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMultiLineField(_companyDetailController, 'Company details...'),
                ],

                const SizedBox(height: 30),
                _buildSectionTitle('Address Details'),
                if (!isGraduate) ...[
                  const SizedBox(height: 12),
                  FormField<double?>(
                    initialValue: _selectedLat,
                    validator: (val) => _selectedLat == null ? 'Location pinning required' : null,
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _showMapPicker,
                          icon: Icon(Icons.map, color: _selectedLat != null ? Colors.green : Colors.blue),
                          label: Text(_selectedLat != null ? 'Location Pinned ✓' : 'Update Office on Map'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: state.hasError ? Colors.red : const Color(0xFF9CA3AF)),
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildLabel('State'),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  isExpanded: true,
                  decoration: _getInputDecoration('Select state', Icons.map_outlined),
                  items: _malaysiaStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _selectedState = val),
                  validator: (val) => val == null ? 'State is required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2, 
                      child: CustomTextField(
                        controller: _cityController, 
                        hintText: 'City', 
                        prefixIcon: Icons.location_city,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1, 
                      child: CustomTextField(
                        controller: _postcodeController, 
                        hintText: 'Postcode', 
                        prefixIcon: Icons.pin_drop, 
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val!.isEmpty) return 'Required';
                          if (val.length != 5 || int.tryParse(val) == null) return 'Invalid';
                          return null;
                        },
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _streetController, 
                  hintText: 'Street Address', 
                  prefixIcon: Icons.home, 
                  maxLines: 2,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                
                const SizedBox(height: 30),
                _buildSectionTitle('Contact Information'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController, 
                  hintText: 'Phone Number', 
                  prefixIcon: Icons.phone, 
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Save Changes',
                  color: primaryColor,
                  onPressed: _saveChanges,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final ampm = parts[1];

      if (ampm == 'PM' && hour < 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  InputDecoration _getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Widget _buildMultiLineField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9CA3AF)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
