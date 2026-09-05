import 'package:latlong2/latlong.dart';

class FilterLogic {
  static double calculateDistance({
    required double? startLat,
    required double? startLng,
    required double? endLat,
    required double? endLng,
  }) {
    if (startLat == null || startLng == null || endLat == null || endLng == null) {
      return double.infinity;
    }
    
    final Distance distance = const Distance();
    return distance.as(LengthUnit.Kilometer, LatLng(startLat, startLng), LatLng(endLat, endLng));
  }

  static List<String> getJobCategories() {
    return ['All', 'IT & Software', 'Finance', 'Engineering', 'Marketing', 'Education', 'Healthcare', 'Other'];
  }

  static List<String> getJobTypes() {
    return ['All', 'Full-time', 'Part-time', 'Internship'];
  }

  static List<String> getCourses() {
    return ['All', 'Computer Science', 'Information Technology', 'Business Administration', 'Mechanical Engineering', 'Accounting', 'Digital Marketing', 'Other'];
  }

  static List<String> getEducationLevels() {
    return ['All', 'Diploma', 'Bachelor\'s Degree', 'Master\'s Degree', 'PhD'];
  }
}
