import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../profile/screens/profile_screen.dart';
import '../../chat/screens/message_list_screen.dart';
import 'home_screen.dart';
import 'market_overview_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainNavigationScreen({Key? key, required this.user, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<MessageListScreenState> _messageKey = GlobalKey<MessageListScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens = [
      HomeScreen(
        key: _homeKey,
        user: widget.user,
        onSwitchTab: (index) => _onTabTapped(index),
      ),
      MarketOverviewScreen(user: widget.user),
      MessageListScreen(key: _messageKey, currentUser: widget.user),
      ProfileScreen(key: _profileKey, user: widget.user),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) {
      _homeKey.currentState?.refresh();
    } else if (index == 2) {
      _messageKey.currentState?.refresh();
    } else if (index == 3) {
      _profileKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: widget.user.role == 'graduate' ? AppColors.graduatePrimary : AppColors.corporatePrimary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), 
              activeIcon: Icon(Icons.home),
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined), 
              activeIcon: Icon(Icons.insights),
              label: 'Insights'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined), 
              activeIcon: Icon(Icons.message),
              label: 'Message'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person),
              label: 'Profile'
            ),
          ],
        ),
      ),
    );
  }
}
