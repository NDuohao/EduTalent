import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../widgets/profile_avatar.dart';

class IndustrialHubsScreen extends StatefulWidget {
  final UserModel currentUser;

  const IndustrialHubsScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<IndustrialHubsScreen> createState() => _IndustrialHubsScreenState();
}

class _IndustrialHubsScreenState extends State<IndustrialHubsScreen> {
  List<UserModel> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final companies = await DatabaseHelper.instance.getAllCompanies();
    if (mounted) {
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    }
  }

  void _showCompanyDetails(BuildContext context, UserModel company) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  imagePath: company.profileImage,
                  name: company.fullName ?? company.username,
                  radius: 30,
                  fallbackIcon: Icons.business,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.fullName ?? company.username,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        company.industry ?? 'General Industry',
                        style: const TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              company.companyDetail ?? 'No company description available.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Map Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              initialCenter: _companies.isNotEmpty 
                ? LatLng(_companies.first.latitude!, _companies.first.longitude!)
                : const LatLng(3.1472, 101.6995),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.edutalent.app',
              ),
              MarkerLayer(
                markers: _companies.map((company) => Marker(
                  point: LatLng(company.latitude!, company.longitude!),
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _showCompanyDetails(context, company),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: ProfileAvatar(
                        imagePath: company.profileImage,
                        name: company.fullName ?? company.username,
                        radius: 25,
                        fallbackIcon: Icons.business,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
    );
  }
}
