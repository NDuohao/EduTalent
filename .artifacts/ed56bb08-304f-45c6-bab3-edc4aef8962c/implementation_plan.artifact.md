# Implementation Plan - Simplifying "Nearby" Logic for Graduates

This plan refines the "Nearby" functionality on the Graduate Home Screen by removing redundant coordinate-based sorting and focusing on reliable state-based filtering.

## User Review Required

> [!IMPORTANT]
> **Removing Distance Sorting**: As requested, I will remove the latitude/longitude sorting logic from the Graduate Home Screen. The "Nearby" toggle will now strictly act as a "State-only" filter to ensure maximum reliability and simplicity.

## Proposed Changes

### 1. Graduate Home Screen Logic Refinement

#### [MODIFY] [graduate_home_screen.dart](file:///C:/Users/User/Desktop/edutalent/lib/features/home/screens/graduate_home_screen.dart)
- **Remove Distance Sort**: Delete the `if (_sortByNearby) { _filteredJobs.sort(...) }` block.
- **Robust State Matching**:
    - Improve the `matchesState` logic to handle potential nulls and case sensitivity more gracefully.
    - Add a fallback to ensure that if a job's `state` is missing but its `location` contains the state name, it still matches (for backward compatibility).

### 2. Verification of Database Content

#### [CHECK] [database_helper.dart](file:///C:/Users/User/Desktop/edutalent/lib/core/database/database_helper.dart)
- Ensure that the `_insertSeedData` method provides consistent state names (e.g., "W.P. Kuala Lumpur" vs "Kuala Lumpur") to match common user profiles.

## Verification Plan

### Manual Verification
1. **Filter Reliability**:
   - Ensure a user with state "Selangor" only sees "Selangor" jobs when the toggle is on.
   - Verify that the list is populated correctly and doesn't become empty if valid matches exist.
2. **Code Cleanliness**:
   - Verify that all `latitude`, `longitude`, and `FilterLogic.calculateDistance` references are removed from `graduate_home_screen.dart`.
