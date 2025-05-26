class MessageModel {
  final int id;
  final int channelId;
  final int userId;
  final String content;
  final String? image;
  final String type;
  final bool read;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.content,
    required this.type,
    required this.read,
    required this.sentAt,
    this.image,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      channelId: json['channel_id'],
      userId: json['user_id'],
      content: json['content'],
      type: json['type'],
      read: json['read'] ?? false,
      sentAt: DateTime.parse(json['sent_at']),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'user_id': userId,
      'content': content,
      'type': type,
      'read': read,
      'sent_at': sentAt.toIso8601String(),
      'image': image,
    };
  }
  MessageModel copyWith({
  int? id,
  int? channelId,
  int? userId,
  String? content,
  String? type,
  bool? read,
  DateTime? sentAt,
  String? image,
}) {
  return MessageModel(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    userId: userId ?? this.userId,
    content: content ?? this.content,
    type: type ?? this.type,
    read: read ?? this.read,
    sentAt: sentAt ?? this.sentAt,
    image: image ?? this.image,
  );
}
}

