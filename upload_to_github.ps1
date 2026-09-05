Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EduTalent Multi-Author Git Upload Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Initialize Git
if (!(Test-Path .git)) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init -b main
}

# Add Remote
git remote add origin https://github.com/NDuohao/EduTalent 2>$null
git remote set-url origin https://github.com/NDuohao/EduTalent

# --- AUTHOR 1: TOEW GUO SHENG ---
Write-Host "Committing Identity & Asset Module (TOEW GUO SHENG)..." -ForegroundColor Green
git add lib/features/auth/*
git add lib/features/profile/*
git add lib/features/notifications/*
git add lib/features/home/screens/saved_*.dart
git add lib/app/*
git add lib/widgets/*
git commit --author="TOEW GUO SHENG <toewgs-wp23@student.tarc.edu.my>" -m "feat: implement Identity & Asset modules (Auth, Profile, Notifications, Widgets)"

# --- AUTHOR 2: NGO DUO HAO ---
Write-Host "Committing Core Business Workflow (NGO DUO HAO)..." -ForegroundColor Green
git add lib/features/home/screens/graduate_home_screen.dart
git add lib/features/home/screens/corporate_home_screen.dart
git add lib/features/home/screens/job_detail_screen.dart
git add lib/features/home/screens/graduate_detail_screen.dart
git add lib/features/home/widgets/*
git add lib/features/profile/screens/add_job_screen.dart
git add lib/features/profile/screens/my_applications_screen.dart
git add lib/features/profile/screens/manage_applications_screen.dart
git add lib/features/profile/screens/my_job_postings_screen.dart
git add lib/core/database/*
git add lib/core/utils/*
git add lib/core/models/user_model.dart
git add lib/core/models/job_model.dart
git add lib/core/models/application_model.dart
git add lib/core/models/notification_model.dart
git commit --author="NGO DUO HAO <ngodh-wp23@student.tarc.edu.my>" -m "feat: implement Core Business Workflow (Job Discovery, Posting, and Application Tracking)"

# --- AUTHOR 3: OSCAR LIM QIAO ZHE ---
Write-Host "Committing Interaction & Intelligence (OSCAR LIM QIAO ZHE)..." -ForegroundColor Green
git add lib/features/chat/*
git add lib/features/home/screens/market_overview_screen.dart
git add lib/features/home/screens/industrial_hubs_screen.dart
git add lib/features/home/screens/main_navigation_screen.dart
git add lib/features/home/screens/home_screen.dart
git add lib/core/services/*
git add lib/core/models/chat_message_model.dart
git add lib/main.dart
git add android/*
git add ios/*
git add windows/*
git add linux/*
git add pubspec.yaml
git add .gitignore
git add analysis_options.yaml
git add .artifacts/*
git commit --author="OSCAR LIM QIAO ZHE <oscarlqz-wp23@student.tarc.edu.my>" -m "feat: implement Interaction & Intelligence modules (Messaging, Market Intel, Maps, and Navigation)"

# Push to GitHub
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
git push -u origin main --force

Write-Host "`nDone! Please check your GitHub repository for contributions." -ForegroundColor Cyan
pause
