class UserModel {
  final int? id;
  final String username;
  final String? fullName;
  final String email;
  final String password;
  final String role;
  
  final String? university;
  final String? course;
  final String? cgpa;
  final String? gradYear;
  
  final String? industry;
  final String? location;
  final String? workingHours;
  final String? companyDetail;

  final String? bio;
  final String? skills;
  final String? experience;
  final String? phone;
  final String? dob;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postcode;
  final String? educationLevel;
  final double? latitude;
  final double? longitude;
  final String? profileImage;
  final String? coverImage;
  final bool isProfileComplete;

  UserModel({
    this.id,
    required this.username,
    this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.university,
    this.course,
    this.cgpa,
    this.gradYear,
    this.industry,
    this.location,
    this.workingHours,
    this.companyDetail,
    this.bio,
    this.skills,
    this.experience,
    this.phone,
    this.dob,
    this.streetAddress,
    this.city,
    this.state,
    this.postcode,
    this.educationLevel,
    this.latitude,
    this.longitude,
    this.profileImage,
    this.coverImage,
    this.isProfileComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'university': university,
      'course': course,
      'cgpa': cgpa,
      'gradYear': gradYear,
      'industry': industry,
      'location': location,
      'workingHours': workingHours,
      'companyDetail': companyDetail,
      'bio': bio,
      'skills': skills,
      'experience': experience,
      'phone': phone,
      'dob': dob,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postcode': postcode,
      'educationLevel': educationLevel,
      'latitude': latitude,
      'longitude': longitude,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'isProfileComplete': isProfileComplete ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      university: map['university'],
      course: map['course'],
      cgpa: map['cgpa'],
      gradYear: map['gradYear'],
      industry: map['industry'],
      location: map['location'],
      workingHours: map['workingHours'],
      companyDetail: map['companyDetail'],
      bio: map['bio'],
      skills: map['skills'],
      experience: map['experience'],
      phone: map['phone'],
      dob: map['dob'],
      streetAddress: map['streetAddress'],
      city: map['city'],
      state: map['state'],
      postcode: map['postcode'],
      educationLevel: map['educationLevel'],
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
      profileImage: map['profileImage'],
      coverImage: map['coverImage'],
      isProfileComplete: map['isProfileComplete'] == 1,
    );
  }
}
