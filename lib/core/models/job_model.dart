class JobModel {
  final int? id;
  final int companyId;
  final String title;
  final String category;
  final String jobType;
  final String location;
  final String? salaryRange;
  final String? workingHours;
  final String? skills;
  final String? description;
  final double? latitude;
  final double? longitude;
  
  final String? companyName;
  final String? companyIndustry;
  final bool isFilled;

  JobModel({
    this.id,
    required this.companyId,
    required this.title,
    required this.category,
    required this.jobType,
    required this.location,
    this.salaryRange,
    this.workingHours,
    this.skills,
    this.description,
    this.latitude,
    this.longitude,
    this.companyName,
    this.companyIndustry,
    this.isFilled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'title': title,
      'category': category,
      'jobType': jobType,
      'location': location,
      'salaryRange': salaryRange,
      'workingHours': workingHours,
      'skills': skills,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'],
      companyId: map['companyId'],
      title: map['title'],
      category: map['category'] ?? 'Other',
      jobType: map['jobType'] ?? 'Full-time',
      location: map['location'],
      salaryRange: map['salaryRange'],
      workingHours: map['workingHours'],
      skills: map['skills'],
      description: map['description'],
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
      companyName: map['fullName'] ?? map['companyName'],
      companyIndustry: map['industry'] ?? map['companyIndustry'],
      isFilled: (map['isFilled'] ?? 0) > 0,
    );
  }
}
