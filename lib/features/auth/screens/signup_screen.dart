import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/email_service.dart';

class SignUpScreen extends StatefulWidget {
  final String role;

  const SignUpScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 1;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _generatedOtp;
  Color get _primaryColor => widget.role == 'graduate' 
      ? AppColors.graduatePrimary 
      : AppColors.corporatePrimary;

  void _sendOtp() async {
    final email = _emailController.text;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered. Please sign in instead.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    _generatedOtp = (Random().nextInt(9000) + 1000).toString();
    
    bool success = await EmailService.sendOtpEmail(email, _generatedOtp!);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent successfully to $email'),
            backgroundColor: _primaryColor,
          ),
        );
        setState(() {
          _currentStep = 2;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send email. Please check your internet or email settings.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() {
        _currentStep = 3;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  Future<void> _completeSignUp() async {
    if (_passwordController.text.isEmpty || _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final newUser = UserModel(
      username: _emailController.text.split('@')[0],
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.role,
    );

    try {
      final db = await dbHelper.database;
      await db.insert('users', newUser.toMap());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_currentStep > 1) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const AppLogo(),
                const SizedBox(height: 20),
                Text(
                  'Sign Up as ${widget.role == 'graduate' ? 'Graduate' : 'Corporate'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Step $_currentStep of 3',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Column(
          children: [
            CustomTextField(
              controller: _emailController,
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Send OTP',
              color: _primaryColor,
              onPressed: _sendOtp,
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Text('We sent a code to ${_emailController.text}'),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _otpController,
              hintText: 'Enter 4-digit OTP',
              prefixIcon: Icons.lock_clock_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Verify OTP',
              color: _primaryColor,
              onPressed: _verifyOtp,
            ),
            TextButton(
              onPressed: _sendOtp,
              child: Text('Resend code', style: TextStyle(color: _primaryColor)),
            )
          ],
        );
      case 3:
        return Column(
          children: [
            CustomTextField(
              controller: _passwordController,
              hintText: 'Create password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm password',
              prefixIcon: Icons.lock_reset_outlined,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Complete Sign Up',
              color: _primaryColor,
              onPressed: _completeSignUp,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
