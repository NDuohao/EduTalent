@echo off
echo ========================================
echo EduTalent - Fixed Path Ownership Upload
echo ========================================

:: 1. Hard Reset
if exist .git (
    rd /s /q .git
)
git init -b main

:: 2. Base Identity
git config user.email "ngodh-wp23@student.tarc.edu.my"
git config user.name "NGO DUO HAO"
git remote add origin https://github.com/NDuohao/EduTalent

:: --- MODULE 1: TOEW GUO SHENG (Identity and Assets) ---
echo Committing Module 1 (TOEW GUO SHENG)...
git add lib/features/auth/
git add lib/features/notifications/
:: FIXED PATHS (Included /screens/ folder)
git add lib/features/profile/screens/complete_profile_screen.dart
git add lib/features/profile/screens/edit_profile_screen.dart
git add lib/features/profile/screens/profile_screen.dart
git add lib/features/home/screens/saved_*.dart
git add lib/widgets/
git add lib/app/
git add assets/
git add lib/core/models/user_model.dart
git add lib/core/models/notification_model.dart
git add lib/core/services/email_service.dart
git commit --author="TOEW GUO SHENG <toewgs-wp23@student.tarc.edu.my>" -m "feat: Identity, Profile and Notification modules with corresponding core models"

:: --- MODULE 2: NGO DUO HAO (Workflow and Platforms) ---
echo Committing Module 2 (NGO DUO HAO)...
git add lib/features/home/screens/graduate_home_screen.dart
git add lib/features/home/screens/corporate_home_screen.dart
git add lib/features/home/screens/job_detail_screen.dart
git add lib/features/home/screens/graduate_detail_screen.dart
git add lib/features/home/widgets/
git add lib/features/profile/screens/add_job_screen.dart
git add lib/features/profile/screens/my_job_postings_screen.dart
git add lib/features/profile/screens/my_applications_screen.dart
git add lib/features/profile/screens/manage_applications_screen.dart
git add lib/features/profile/widgets/applicant_profile_view.dart
git add lib/core/models/job_model.dart
git add lib/core/models/application_model.dart
git add lib/core/utils/filter_logic.dart
git add android/
git add ios/
git add windows/
git add linux/
git add web/
git add pubspec.*
git add .gitignore
git add README.md
git add analysis_options.yaml
git commit --author="NGO DUO HAO <ngodh-wp23@student.tarc.edu.my>" -m "feat: Business Workflow modules and project platform configuration"

:: --- MODULE 3: OSCAR LIM QIAO ZHE (Interaction and Database Logic) ---
echo Committing Module 3 (OSCAR LIM QIAO ZHE)...
git add lib/features/chat/
git add lib/features/home/screens/market_overview_screen.dart
git add lib/features/home/screens/industrial_hubs_screen.dart
git add lib/features/home/screens/main_navigation_screen.dart
git add lib/features/home/screens/home_screen.dart
git add lib/core/database/
git add lib/core/models/chat_message_model.dart
git add lib/core/services/open_data_service.dart
git add lib/main.dart
:: Catch any other artifacts or remaining files
git add .
git commit --author="OSCAR LIM QIAO ZHE <oscarlqz-wp23@student.tarc.edu.my>" -m "feat: Messaging, Market Intelligence and core Database architecture"

:: 3. Final Push
echo.
echo Pushing to GitHub (Full Reset to Fix Paths)...
git push -u origin main --force

echo.
echo Done! Please refresh your GitHub and check those 3 files.
pause
