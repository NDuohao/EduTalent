import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/job_model.dart';
import '../../../widgets/skill_tag_input.dart';
import 'package:intl/intl.dart';

class AddJobScreen extends StatefulWidget {
  final UserModel company;
  final JobModel? job;

  const AddJobScreen({Key? key, required this.company, this.job}) : super(key: key);

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherCategoryController = TextEditingController();

  String? _selectedCategory;
  String? _selectedType;
  String? _selectedState;
  String? _selectedStartTime;
  String? _selectedEndTime;
  bool _useCompanyAddress = true;
  List<String> _skillList = [];
  
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _titleController.text = widget.job!.title;
      _descriptionController.text = widget.job!.description ?? '';
      _skillList = widget.job!.skills?.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() ?? [];
      
      if (_categories.contains(widget.job!.category)) {
        _selectedCategory = widget.job!.category;
      } else {
        _selectedCategory = 'Other';
        _otherCategoryController.text = widget.job!.category;
      }

      _selectedType = widget.job!.jobType;

      if (widget.job!.salaryRange != null && widget.job!.salaryRange!.startsWith('RM ')) {
        final parts = widget.job!.salaryRange!.replaceAll('RM ', '').split(' - ');
        if (parts.length == 2) {
          _minSalaryController.text = parts[0];
          _maxSalaryController.text = parts[1];
        }
      }

      if (widget.job!.workingHours != null && widget.job!.workingHours!.contains(' - ')) {
        final times = widget.job!.workingHours!.split(' - ');
        if (times.length == 2) {
          _selectedStartTime = times[0];
          _selectedEndTime = times[1];
        }
      }

      final companyAddress = "${widget.company.streetAddress ?? ''}, ${widget.company.city ?? ''}, ${widget.company.state ?? ''}";
      if (widget.job!.location == companyAddress) {
        _useCompanyAddress = true;
      } else {
        _useCompanyAddress = false;
        final locParts = widget.job!.location.split(', ');
        if (locParts.length >= 3) {
          _selectedState = locParts.last;
          _cityController.text = locParts[locParts.length - 2];
          _streetController.text = locParts.sublist(0, locParts.length - 2).join(', ');
        }
      }

      _selectedLat = widget.job!.latitude;
      _selectedLng = widget.job!.longitude;
    }
  }

  final List<String> _categories = [
    'Technology & IT', 'Business & Finance', 'Healthcare', 'Engineering',
    'Arts & Design', 'Education', 'Sales & Marketing', 'Hospitality', 'Other'
  ];

  final List<String> _employmentTypes = ['Full-time', 'Part-time', 'Internship'];

  final List<String> _malaysiaStates = [
    'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan', 'Pahang',
    'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak', 'Selangor',
    'Terengganu', 'W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya'
  ];

  final List<String> _timeSlots = [
    '07:00 AM', '07:30 AM', '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
    '07:00 PM', '07:30 PM', '08:00 PM', '08:30 PM', '09:00 PM', '09:30 PM', '10:00 PM'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _descriptionController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
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
                    const Text('Pin Job Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    String finalLocation = _useCompanyAddress
        ? "${widget.company.streetAddress ?? ''}, ${widget.company.city ?? ''}, ${widget.company.state ?? ''}"
        : "${_streetController.text}, ${_cityController.text}, $_selectedState";

    final currencyFormat = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ', decimalDigits: 2);
    final double? minSal = double.tryParse(_minSalaryController.text);
    final double? maxSal = double.tryParse(_maxSalaryController.text);

    String finalSalary = "RM ${_minSalaryController.text} - RM ${_maxSalaryController.text}";
    if (minSal != null && maxSal != null) {
      finalSalary = "${currencyFormat.format(minSal)} - ${currencyFormat.format(maxSal)}";
    }

    String finalHours = "$_selectedStartTime - $_selectedEndTime";
    String finalCategory = (_selectedCategory == 'Other') ? _otherCategoryController.text : _selectedCategory!;

    final db = await DatabaseHelper.instance.database;
    final jobData = JobModel(
      id: widget.job?.id,
      companyId: widget.company.id!,
      title: _titleController.text,
      category: finalCategory,
      jobType: _selectedType!,
      location: finalLocation,
      salaryRange: finalSalary,
      workingHours: finalHours,
      skills: _skillList.map((s) => s.trim().toUpperCase()).join(', '),
      description: _descriptionController.text,
      latitude: _useCompanyAddress ? widget.company.latitude : _selectedLat,
      longitude: _useCompanyAddress ? widget.company.longitude : _selectedLng,
    );

    if (widget.job == null) {
      await db.insert('jobs', jobData.toMap());

      await DatabaseHelper.instance.notifyUsersBySkillMatch(
        role: 'graduate',
        title: 'New Job Opportunity!',
        message: '${widget.company.fullName} just posted a new vacancy: ${_titleController.text}',
        type: 'job',
        targetSkills: _skillList.join(', '),
      );
    } else {
      await db.update(
        'jobs',
        jobData.toMap(),
        where: 'id = ?',
        whereArgs: [widget.job!.id],
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'Post New Job' : 'Edit Job Vacancy'),
        backgroundColor: AppColors.corporatePrimary,
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
                _buildSectionTitle('Position Information'),
                const SizedBox(height: 16),
                _buildLabel('Job Title'),
                CustomTextField(
                  controller: _titleController,
                  hintText: 'e.g. Software Engineer',
                  prefixIcon: Icons.work_outline,
                  validator: (val) => val!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Category'),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: _getInputDecoration('Select Category', Icons.category_outlined),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedCategory = val;
                    if (val != 'Other') {
                      _otherCategoryController.clear();
                    }
                  }),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: 12),
                  _buildLabel('Specify Category'),
                  CustomTextField(
                    controller: _otherCategoryController,
                    hintText: 'Enter your business category',
                    prefixIcon: Icons.edit_note,
                    validator: (val) => (_selectedCategory == 'Other' && val!.isEmpty) ? 'Please specify' : null,
                  ),
                ],
                const SizedBox(height: 16),
                _buildLabel('Job Type'),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  isExpanded: true,
                  decoration: _getInputDecoration('Select Type', Icons.assignment_outlined),
                  items: _employmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Location'),
                SwitchListTile(
                  title: const Text('Use Company Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(_useCompanyAddress ? '${widget.company.city}, ${widget.company.state}' : 'Specify different location', style: const TextStyle(fontSize: 12)),
                  value: _useCompanyAddress,
                  activeColor: AppColors.corporatePrimary,
                  onChanged: (val) => setState(() => _useCompanyAddress = val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!_useCompanyAddress) ...[
                  const SizedBox(height: 8),
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
                  _buildLabel('City'),
                  CustomTextField(
                    controller: _cityController,
                    hintText: 'e.g. Petaling Jaya',
                    prefixIcon: Icons.location_city,
                    validator: (val) => val!.isEmpty ? 'City is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('Street Address'),
                  CustomTextField(
                    controller: _streetController,
                    hintText: 'Unit number, street name...',
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                    validator: (val) => val!.isEmpty ? 'Street address is required' : null,
                  ),
                  const SizedBox(height: 12),
                  FormField<double?>(
                    initialValue: _selectedLat,
                    validator: (val) => _selectedLat == null ? 'Location pinning required' : null,
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _showMapPicker();
                          },
                          icon: Icon(Icons.map, color: _selectedLat != null ? Colors.green : Colors.blue),
                          label: Text(_selectedLat != null ? 'Location Pinned ✓' : 'Pin Job Location on Map'),
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
                const SizedBox(height: 30),
                _buildSectionTitle('Salary & Hours'),
                const SizedBox(height: 16),
                _buildLabel('Salary Range (RM / Month)'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _minSalaryController, 
                        hintText: 'Min', 
                        prefixIcon: Icons.payments_outlined, 
                        keyboardType: TextInputType.number,
                        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 16, left: 8, right: 8), child: Text('-')),
                    Expanded(
                      child: CustomTextField(
                        controller: _maxSalaryController, 
                        hintText: 'Max', 
                        prefixIcon: Icons.payments_outlined, 
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final max = double.tryParse(val);
                          final min = double.tryParse(_minSalaryController.text);
                          if (max != null && min != null && max < min) return 'Must be > Min';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Working Hours'),
                DropdownButtonFormField<String>(
                  value: _selectedStartTime,
                  isExpanded: true,
                  decoration: _getInputDecoration('Start Time', Icons.access_time),
                  items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedStartTime = val),
                  validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 30),
                _buildSectionTitle('Requirements'),
                const SizedBox(height: 16),
                _buildLabel('Key Skills'),
                FormField<List<String>>(
                  initialValue: _skillList,
                  validator: (val) => (val == null || val.isEmpty) ? 'Please add at least one skill' : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkillTagInput(
                          initialSkills: _skillList,
                          onChanged: (newList) {
                            _skillList = newList;
                            state.didChange(newList);
                          },
                          hintText: 'Add skill (e.g. Flutter)...',
                          hasError: state.hasError,
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Job Description'),
                _buildMultiLineField(
                  _descriptionController, 
                  'Outline the responsibilities and requirements...',
                  (val) => val!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: widget.job == null ? 'Post Vacancy' : 'Save Changes',
                  color: AppColors.corporatePrimary,
                  onPressed: _saveJob,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  InputDecoration _getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[700], size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9CA3AF))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Widget _buildMultiLineField(TextEditingController controller, String hint, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE5E7EB),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
