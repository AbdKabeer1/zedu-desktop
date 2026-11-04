class UserMentionActivityModel {
  const UserMentionActivityModel({
    required this.id,
    required this.messageId,
    required this.channelId,
    required this.channelName,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String messageId;
  final String channelId;
  final String channelName;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final DateTime createdAt;

  factory UserMentionActivityModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is int) {
        return value > 10000000000
            ? DateTime.fromMillisecondsSinceEpoch(value)
            : DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return UserMentionActivityModel(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      messageId: (json['message_id'] ?? json['messageId'] ?? '') as String,
      channelId: (json['channel_id'] ?? json['channelId'] ?? '') as String,
      channelName:
          (json['channel_name'] ?? json['channelName'] ?? '') as String,
      senderName: (json['sender_name'] ?? json['senderName'] ?? '') as String,
      senderAvatarUrl:
          json['sender_avatar_url'] as String? ??
          json['senderAvatarUrl'] as String? ??
          json['avatar_url'] as String?,
      content: (json['content'] ?? '') as String,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message_id': messageId,
    'channel_id': channelId,
    'channel_name': channelName,
    'sender_name': senderName,
    'sender_avatar_url': senderAvatarUrl,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMentionActivityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          messageId == other.messageId &&
          channelId == other.channelId &&
          channelName == other.channelName &&
          senderName == other.senderName &&
          senderAvatarUrl == other.senderAvatarUrl &&
          content == other.content &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    channelId,
    channelName,
    senderName,
    senderAvatarUrl,
    content,
    createdAt,
  );
}
