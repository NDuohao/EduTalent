import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import 'corporate_home_screen.dart';
import 'graduate_home_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final Function(int)? onSwitchTab;

  const HomeScreen({Key? key, required this.user, this.onSwitchTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CorporateHomeScreenState> _corpKey = GlobalKey();
  final GlobalKey<GraduateHomeScreenState> _gradKey = GlobalKey();

  void refresh() {
    if (widget.user.role == 'corporate') {
      _corpKey.currentState?.refresh();
    } else {
      _gradKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.role == 'corporate') {
      return CorporateHomeScreen(key: _corpKey, user: widget.user, onSwitchTab: widget.onSwitchTab);
    }
    
    return GraduateHomeScreen(key: _gradKey, user: widget.user, onSwitchTab: widget.onSwitchTab);
  }
}
