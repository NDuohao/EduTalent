@echo off
echo ========================================
echo EduTalent - "Add files via upload" Style
echo ========================================

:: 1. Hard Reset local git history to start fresh
if exist .git (
    rd /s /q .git
)
git init -b main

:: 2. Base Identity (The project creator)
git config user.email "ngodh-wp23@student.tarc.edu.my"
git config user.name "NGO DUO HAO"
git remote add origin https://github.com/NDuohao/EduTalent

:: --- MODULE 1: TOEW GUO SHENG ---
echo Committing Module 1...
git add lib/features/auth/
git add lib/features/notifications/
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
git commit --author="TOEW GUO SHENG <toewgs-wp23@student.tarc.edu.my>" -m "Add files via upload"

:: --- MODULE 2: NGO DUO HAO ---
echo Committing Module 2...
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
git commit --author="NGO DUO HAO <ngodh-wp23@student.tarc.edu.my>" -m "Add files via upload"

:: --- MODULE 3: OSCAR LIM QIAO ZHE ---
echo Committing Module 3...
git add lib/features/chat/
git add lib/features/home/screens/market_overview_screen.dart
git add lib/features/home/screens/industrial_hubs_screen.dart
git add lib/features/home/screens/main_navigation_screen.dart
git add lib/features/home/screens/home_screen.dart
git add lib/core/database/
git add lib/core/models/chat_message_model.dart
git add lib/core/services/open_data_service.dart
git add lib/main.dart
:: Catch remaining files (like artifacts)
git add .
git commit --author="OSCAR LIM QIAO ZHE <oscarlqz-wp23@student.tarc.edu.my>" -m "Add files via upload"

:: 3. Final Push
echo.
echo Pushing to GitHub (Full Reset for visual style)...
git push -u origin main --force

echo.
echo Done! GitHub will now show "Add files via upload" for all folders.
pause
