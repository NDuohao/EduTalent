import 'package:flutter/material.dart';
import 'dart:math';
import '../../../app/constants/app_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/email_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? role;

  const ForgotPasswordScreen({Key? key, this.role}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  String? _generatedOtp;
  bool _isSending = false;

  Color get _primaryColor => widget.role == 'corporate' 
      ? AppColors.corporatePrimary 
      : AppColors.graduatePrimary;

  Future<void> _checkEmailAndSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    setState(() => _isSending = true);

    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (users.isEmpty) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email not found in our records')));
      }
      return;
    }

    _generatedOtp = (Random().nextInt(9000) + 1000).toString();
    final success = await EmailService.sendOtpEmail(email, _generatedOtp!);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        setState(() => _currentStep = 1);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send email. Please check internet.')));
      }
    }
  }

  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() => _currentStep = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP. Please try again.')));
    }
  }

  Future<void> _resetPassword() async {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    await DatabaseHelper.instance.updatePassword(_emailController.text.trim(), pass);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated! Please sign in.'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const AppLogo(),
              const SizedBox(height: 30),
              Text(
                _getStepTitle(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _getStepSubtitle(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              if (_currentStep == 0) _buildEmailStep(),
              if (_currentStep == 1) _buildOtpStep(),
              if (_currentStep == 2) _buildPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    if (_currentStep == 0) return 'Reset Password';
    if (_currentStep == 1) return 'Verify OTP';
    return 'New Password';
  }

  String _getStepSubtitle() {
    if (_currentStep == 0) return 'Enter your email to receive a verification code';
    if (_currentStep == 1) return 'Enter the 4-digit code sent to ${_emailController.text}';
    return 'Create a strong new password for your account';
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        CustomTextField(controller: _emailController, hintText: 'Email Address', prefixIcon: Icons.email_outlined),
        const SizedBox(height: 32),
        _isSending 
          ? const CircularProgressIndicator()
          : CustomButton(text: 'Send OTP', color: _primaryColor, onPressed: _checkEmailAndSendOtp),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        CustomTextField(controller: _otpController, hintText: 'Enter 4-digit OTP', prefixIcon: Icons.lock_clock_outlined, keyboardType: TextInputType.number),
        const SizedBox(height: 32),
        CustomButton(text: 'Verify OTP', color: _primaryColor, onPressed: _verifyOtp),
        TextButton(onPressed: _checkEmailAndSendOtp, child: Text('Resend Code', style: TextStyle(color: _primaryColor))),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        CustomTextField(controller: _passwordController, hintText: 'New Password', prefixIcon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        CustomTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', prefixIcon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 32),
        CustomButton(text: 'Update Password', color: _primaryColor, onPressed: _resetPassword),
      ],
    );
  }
}
