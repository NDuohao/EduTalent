import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';
import '../../../widgets/custom_button.dart';
import 'graduate_signin.dart';
import 'corporate_signin.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    AppAssets.logo,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 30,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Edu',
                          style: TextStyle(color: AppColors.graduatePrimary),
                        ),
                        TextSpan(
                          text: 'Talent',
                          style: TextStyle(color: AppColors.corporatePrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bridge the Gap Between\nFresh Graduates and\nMalaysia\'s Industrial Hubs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'SDG 9 data-driven matching connecting\ntalent to innovation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'I am a Graduate',
              color: AppColors.graduatePrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GraduateSignInScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'I am a Corporate Recruiter',
              color: AppColors.corporatePrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CorporateSignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
