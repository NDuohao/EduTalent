# Implementation Plan - Talent Filtering & Real-time Refresh

This plan ensures that graduates who have already been hired (status 'Accepted') are correctly hidden from the corporate user's talent discovery list, and that the home screen data stays up-to-date when navigating between tabs.

## User Review Required

> [!IMPORTANT]
> **Refresh Logic**: I am adding a "Tab Refresh" mechanism to the main navigation. This means every time you tap the "Home" icon at the bottom, it will now force a refresh of the job/talent list to ensure you see the latest statuses (e.g., hiding people you just hired).

## Proposed Changes

### 1. Navigation & Refresh Sync

#### [MODIFY] [corporate_home_screen.dart](file:///C:/Users/User/Desktop/edutalent/lib/features/home/screens/corporate_home_screen.dart)
- Add a public `refresh()` method to the state class that calls `_loadInitialData()`.
- Add a `GlobalKey` support if needed.

#### [MODIFY] [graduate_home_screen.dart](file:///C:/Users/User/Desktop/edutalent/lib/features/home/screens/graduate_home_screen.dart)
- Add a public `refresh()` method.

#### [MODIFY] [home_screen.dart](file:///C:/Users/User/Desktop/edutalent/lib/features/home/screens/home_screen.dart)
- Convert to a `StatefulWidget`.
- Expose a `refresh()` method that passes the call down to the active home screen (Graduate or Corporate).

#### [MODIFY] [main_navigation_screen.dart](file:///C:/Users/User/Desktop/edutalent/lib/features/home/screens/main_navigation_screen.dart)
- Define a `GlobalKey<HomeScreenState>` for the home screen.
- Update `_onTabTapped` to call `_homeKey.currentState?.refresh()` when index 0 is selected.

### 2. Database Filter Verification

#### [VERIFY] [database_helper.dart](file:///C:/Users/User/Desktop/edutalent/lib/core/database/database_helper.dart)
- Double-check `getGraduatesForCorporate` SQL logic.
- Ensure `getAppliedStudentIds` (used for the 'APPLICANT' tag) also reflects the hidden state where appropriate.

## Verification Plan

### Manual Verification
1. **Hiring Flow**:
   - Login as Corporate.
   - Note a candidate (e.g., John Doe) on the Home screen.
   - Go to Profile -> Manage Applications.
   - Accept John Doe.
   - Tap the "Home" tab icon.
   - **Success Condition**: John Doe should no longer appear in the "Best Matches" list.
2. **Tab Switch**: Verify that switching between Message, Insights, and Home correctly updates the counts and lists without requiring a manual pull-to-refresh.
