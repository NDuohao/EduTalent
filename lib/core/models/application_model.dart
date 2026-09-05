class ApplicationModel {
  final int? id;
  final int jobId;
  final int userId;
  final String status;
  final String timestamp;

  ApplicationModel({
    this.id,
    required this.jobId,
    required this.userId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'userId': userId,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'],
      jobId: map['jobId'],
      userId: map['userId'],
      status: map['status'],
      timestamp: map['timestamp'],
    );
  }
}
