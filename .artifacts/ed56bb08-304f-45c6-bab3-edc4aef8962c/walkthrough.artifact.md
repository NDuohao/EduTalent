# Walkthrough - Real-time Talent Refresh & Filtering

I have implemented an automatic refresh mechanism for the Home screen to ensure that graduates who are hired (status 'Accepted') immediately disappear from the talent discovery list.

## Changes Made

### 1. Automatic Tab Refresh
Modified the main navigation framework (`MainNavigationScreen`) so that every time you tap the **Home** icon in the bottom navigation bar, it triggers a refresh of the content. This ensures you always see the most accurate data without needing to manually restart the app.

### 2. HomeScreen Delegation
Refactored `HomeScreen` from a `StatelessWidget` to a `StatefulWidget` to support state management via `GlobalKey`. It now acts as a bridge, passing refresh commands down to either the `CorporateHomeScreen` or `GraduateHomeScreen`.

### 3. State Exposure
Made the state classes for Corporate and Graduate home screens public (`CorporateHomeScreenState` and `GraduateHomeScreenState`) and added a `refresh()` method to both. This allows the navigation controller to safely reach in and tell them to reload their data from the database.

## Verification Results

> [!IMPORTANT]
> To verify this, simply **hire a candidate** in the 'Manage Applications' screen and then **tap the Home icon**. The hired candidate will be filtered out automatically.

| Scenario | Action | Expected Result |
| :--- | :--- | :--- |
| Candidate Hired | Manage Apps -> Accept | Candidate moves to History tab |
| Return to Home | Tap Home icon | Candidate no longer appears in "Best Matches" |
| Switch Tabs | Insights -> Home | Home screen data reloads to ensure sync |
