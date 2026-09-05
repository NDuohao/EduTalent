import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SkillTagInput extends StatefulWidget {
  final List<String> initialSkills;
  final Function(List<String>) onChanged;
  final String hintText;
  final bool hasError;

  const SkillTagInput({
    Key? key,
    required this.initialSkills,
    required this.onChanged,
    this.hintText = 'Add a skill...',
    this.hasError = false,
  }) : super(key: key);

  @override
  State<SkillTagInput> createState() => _SkillTagInputState();
}

class _SkillTagInputState extends State<SkillTagInput> {
  late List<String> _skills;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.initialSkills);
  }

  void _addSkill() {
    final text = _controller.text.trim().toUpperCase();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _controller.clear();
      });
      widget.onChanged(_skills);
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
    widget.onChanged(_skills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasError ? Colors.red : const Color(0xFF9CA3AF),
              width: widget.hasError ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_skills.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: _skills.map((skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeSkill(skill),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.blue.withOpacity(0.2)),
                    )).toList(),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: _addSkill,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
