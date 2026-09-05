import 'package:flutter/material.dart';
import '../app/constants/app_colors.dart';
import '../app/constants/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Image.asset(
            AppAssets.logo,
            width: 180,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 0,
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Edu', style: TextStyle(color: AppColors.graduatePrimary)),
                TextSpan(text: 'Talent', style: TextStyle(color: AppColors.corporatePrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
