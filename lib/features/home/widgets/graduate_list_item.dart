import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../widgets/profile_avatar.dart';
import '../screens/graduate_detail_screen.dart';

class GraduateListItem extends StatelessWidget {
  final UserModel graduate;
  final UserModel currentUser;
  final bool isSaved;
  final bool isApplicant;
  final VoidCallback onSaveToggle;
  final VoidCallback? onRefresh;

  const GraduateListItem({
    Key? key, 
    required this.graduate,
    required this.currentUser,
    required this.isSaved,
    this.isApplicant = false,
    required this.onSaveToggle,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GraduateDetailScreen(
              graduateId: graduate.id!,
              currentUser: currentUser,
            ),
          ),
        ).then((_) => onRefresh?.call());
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
          border: Border.all(color: isApplicant ? Colors.green.withOpacity(0.3) : Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              imagePath: graduate.profileImage,
              name: graduate.fullName ?? graduate.username,
              radius: 35,
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
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                graduate.fullName ?? graduate.username,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isApplicant) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                                child: const Text('APPLICANT', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ]
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 22,
                          color: isSaved ? Colors.blue : Colors.grey,
                        ),
                        onPressed: onSaveToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${graduate.university ?? 'Unknown University'} • ${graduate.course ?? 'General Course'}',
                    style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(graduate.educationLevel ?? 'Degree', Colors.purple[50]!, Colors.purple[800]!),
                      _buildTag('CGPA: ${double.tryParse(graduate.cgpa ?? '0.00')?.toStringAsFixed(2) ?? '0.00'}', Colors.blue[50]!, Colors.blue[800]!),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        graduate.state ?? 'Malaysia',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (graduate.skills != null && graduate.skills!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: graduate.skills!.split(',').map((skill) {
                        if (skill.trim().isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(skill.trim(), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraduateDetailScreen(
                              graduateId: graduate.id!,
                              currentUser: currentUser,
                            ),
                          ),
                        ).then((_) => onRefresh?.call());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: const Text('View Talent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
}
