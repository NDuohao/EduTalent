import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../home/screens/main_navigation_screen.dart';
import 'package:intl/intl.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel user;

  const CompleteProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  
  final _universityController = TextEditingController();
  final _courseController = TextEditingController();
  final _cgpaController = TextEditingController();
  String? _selectedEducationLevel;
  final List<String> _educationLevels = ['Diploma', 'Degree', 'Master', 'PhD', 'Other'];
  
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  String? _selectedState;
  final List<String> _malaysiaStates = [
    'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan', 'Pahang', 
    'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak', 'Selangor', 
    'Terengganu', 'W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya'
  ];

  final _industryController = TextEditingController();
  final _locationController = TextEditingController(); 
  
  String? _selectedWorkingDays;
  String? _selectedStartTime;
  String? _selectedEndTime;

  final List<String> _workingDayOptions = [
    'Monday - Friday', 'Monday - Saturday', 'Monday - Sunday'
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    _cgpaController.dispose();
    _dobController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _phoneController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() {
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        _dobController.text = "$day/$month/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      dob: widget.user.role == 'graduate' ? _dobController.text : null,
      streetAddress: _streetController.text,
      city: _cityController.text,
      state: _selectedState,
      postcode: _postcodeController.text,
      phone: _phoneController.text,
      latitude: _selectedLat,
      longitude: _selectedLng,
      isProfileComplete: true,
      skills: '',
      experience: '',
      bio: '',
    );

    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [widget.user.id],
    );


    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen(user: updatedUser)),
      );
    }
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
                    const Text('Tap to Pin Office Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    bool isGraduate = widget.user.role == 'graduate';
    final primaryColor = isGraduate ? AppColors.graduatePrimary : AppColors.corporatePrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
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
                  child: Text(
                    isGraduate 
                      ? 'Tell us more about yourself and your academic background'
                      : 'Tell us more about your company and industry',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildLabel(isGraduate ? 'Full Name' : 'Company Name'),
                CustomTextField(
                  controller: _fullNameController,
                  hintText: isGraduate ? 'Your name' : 'Registered company name',
                  prefixIcon: isGraduate ? Icons.person_outline : Icons.business,
                  validator: (val) => val!.isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 20),

                if (isGraduate) ...[
                  _buildLabel('Date of Birth'),
                CustomTextField(
                  controller: _dobController,
                  hintText: 'Tap to select birth date',
                  prefixIcon: Icons.cake_outlined,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 20),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (val) => val!.isEmpty ? 'Please select your birthday' : null,
                ),
                const SizedBox(height: 20),
                ],

                if (isGraduate) ...[
                  _buildLabel('Education Level'),
                  DropdownButtonFormField<String>(
                    value: _selectedEducationLevel,
                    isExpanded: true,
                    decoration: _getInputDecoration('Select level', Icons.school_outlined),
                    items: _educationLevels.map((String level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedEducationLevel = val),
                    validator: (val) => val == null ? 'Please select your level' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('University Name'),
                  CustomTextField(
                    controller: _universityController,
                    hintText: 'e.g. University of Malaya',
                    prefixIcon: Icons.account_balance_outlined,
                    validator: (val) => val!.isEmpty ? 'University name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Course of Study'),
                  CustomTextField(
                    controller: _courseController,
                    hintText: 'e.g. Computer Science',
                    prefixIcon: Icons.book_outlined,
                    validator: (val) => val!.isEmpty ? 'Course name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('CGPA'),
                  CustomTextField(
                    controller: _cgpaController,
                    hintText: 'e.g. 3.85',
                    prefixIcon: Icons.grade_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'CGPA is required';
                      final num = double.tryParse(val);
                      if (num == null) return 'Enter a valid number';
                      if (num < 2.0 || num > 4.0) return 'Must be between 2.00 - 4.00';
                      return null;
                    },
                  ),
                ] else ...[
                  _buildLabel('Industry'),
                  CustomTextField(
                    controller: _industryController,
                    hintText: 'e.g. Fintech & Banking',
                    prefixIcon: Icons.category_outlined,
                    validator: (val) => val!.isEmpty ? 'Industry is required' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  const SizedBox(height: 12),

                  _buildLabel('Working Schedule'),
                  DropdownButtonFormField<String>(
                    value: _selectedWorkingDays,
                    isExpanded: true,
                    decoration: _getInputDecoration('Select working days', Icons.calendar_month_outlined),
                    items: _workingDayOptions.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                    onChanged: (val) => setState(() => _selectedWorkingDays = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Start Time'),
                  DropdownButtonFormField<String>(
                    value: _selectedStartTime,
                    isExpanded: true,
                    decoration: _getInputDecoration('Start', Icons.access_time),
                    items: _timeSlots.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                    onChanged: (val) => setState(() => _selectedStartTime = val),
                    validator: (val) => val == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('End Time'),
                  DropdownButtonFormField<String>(
                    value: _selectedEndTime,
                    isExpanded: true,
                    decoration: _getInputDecoration('End', Icons.access_time_filled),
                    items: _timeSlots.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
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
                ],

                const SizedBox(height: 24),
                const Divider(),
                const Text('Address Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          label: Text(_selectedLat != null ? 'Location Pinned ✓' : 'Pin Office on Map'),
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
                  items: _malaysiaStates.map((String state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedState = val),
                  validator: (val) => val == null ? 'Please select your state' : null,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('City'),
                          CustomTextField(
                            controller: _cityController,
                            hintText: 'e.g. Petaling Jaya',
                            prefixIcon: Icons.location_city,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Postcode'),
                          CustomTextField(
                            controller: _postcodeController,
                            hintText: 'e.g. 47301',
                            prefixIcon: Icons.pin_drop,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val!.isEmpty) return 'Required';
                              if (val.length != 5 || int.tryParse(val) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Street Address'),
                CustomTextField(
                  controller: _streetController,
                  hintText: 'Unit number, street name...',
                  prefixIcon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (val) => val!.isEmpty ? 'Street address is required' : null,
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                _buildLabel('Phone Number'),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'e.g. 0123456789',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? 'Phone number is required' : null,
                ),
                
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Save and Continue',
                  color: primaryColor,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      ),
    );
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

  InputDecoration _getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
