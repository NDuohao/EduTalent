import 'package:flutter/material.dart';
import 'dart:io';

class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final IconData? fallbackIcon;

  const ProfileAvatar({
    Key? key,
    this.imagePath,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.fallbackIcon,
  }) : super(key: key);

  ImageProvider? _getProvider() {
    if (imagePath == null || imagePath!.isEmpty) return null;
    
    if (imagePath!.startsWith('http')) {
      return NetworkImage(imagePath!);
    }
    
    final file = File(imagePath!);
    if (file.existsSync()) {
      return FileImage(file);
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _getProvider();
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.blue.withValues(alpha: 0.1),
      backgroundImage: provider,
      child: provider == null
          ? (name != null && name!.isNotEmpty
              ? Text(
                  name![0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                )
              : Icon(fallbackIcon ?? Icons.person, color: Colors.blue, size: radius))
          : null,
    );
  }
}
