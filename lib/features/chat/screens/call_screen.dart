import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../widgets/profile_avatar.dart';

class CallScreen extends StatefulWidget {
  final UserModel contact;
  final bool isVideo;

  const CallScreen({Key? key, required this.contact, this.isVideo = false}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  ProfileAvatar(
                    imagePath: widget.contact.profileImage,
                    name: widget.contact.fullName ?? widget.contact.username,
                    radius: 60,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.contact.fullName ?? widget.contact.username,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isVideo ? 'Video Calling...' : 'Voice Calling...',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: 'Mute',
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    active: _isMuted,
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'Hang Up',
                    onTap: () => Navigator.pop(context),
                    color: Colors.red,
                  ),
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    active: _isSpeakerOn,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white24,
    bool active = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active ? Colors.blue : color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
