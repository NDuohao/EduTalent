class NotificationModel {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String timestamp;
  final bool isRead;
  final int? jobId;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.jobId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
      'jobId': jobId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] == 1,
      jobId: map['jobId'],
    );
  }
}
