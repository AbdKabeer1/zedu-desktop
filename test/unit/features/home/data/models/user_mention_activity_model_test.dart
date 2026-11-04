import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/home/home.dart';

void main() {
  group('UserMentionActivityModel', () {
    final testDate = DateTime.utc(2026, 11, 4, 12, 0, 0);

    test('deserializes from standard snake_case JSON payload', () {
      final json = <String, dynamic>{
        'id': 'mention-1',
        'message_id': 'msg-100',
        'channel_id': 'chan-200',
        'channel_name': 'general',
        'sender_name': 'Alice Smith',
        'sender_avatar_url': 'https://example.com/avatar.png',
        'content': 'Hey @Bob check this out',
        'created_at': testDate.toIso8601String(),
      };

      final model = UserMentionActivityModel.fromJson(json);

      expect(model.id, 'mention-1');
      expect(model.messageId, 'msg-100');
      expect(model.channelId, 'chan-200');
      expect(model.channelName, 'general');
      expect(model.senderName, 'Alice Smith');
      expect(model.senderAvatarUrl, 'https://example.com/avatar.png');
      expect(model.content, 'Hey @Bob check this out');
      expect(model.createdAt, testDate);
    });

    test('deserializes alternative camelCase fields and null avatar', () {
      final json = <String, dynamic>{
        '_id': 'mention-alt',
        'messageId': 'msg-alt',
        'channelId': 'chan-alt',
        'channelName': 'announcements',
        'senderName': 'Charlie',
        'content': 'Welcome everyone',
        'createdAt': testDate.toIso8601String(),
      };

      final model = UserMentionActivityModel.fromJson(json);

      expect(model.id, 'mention-alt');
      expect(model.messageId, 'msg-alt');
      expect(model.channelId, 'chan-alt');
      expect(model.channelName, 'announcements');
      expect(model.senderName, 'Charlie');
      expect(model.senderAvatarUrl, isNull);
      expect(model.content, 'Welcome everyone');
      expect(model.createdAt, testDate);
    });

    test('parses timestamp from epoch seconds and milliseconds', () {
      final epochSeconds = testDate.millisecondsSinceEpoch ~/ 1000;
      final modelFromSeconds = UserMentionActivityModel.fromJson({
        'id': '1',
        'message_id': 'm1',
        'channel_id': 'c1',
        'channel_name': 'c',
        'sender_name': 's',
        'content': 'hi',
        'created_at': epochSeconds,
      });

      expect(
        modelFromSeconds.createdAt.millisecondsSinceEpoch,
        epochSeconds * 1000,
      );

      final epochMillis = testDate.millisecondsSinceEpoch;
      final modelFromMillis = UserMentionActivityModel.fromJson({
        'id': '2',
        'message_id': 'm2',
        'channel_id': 'c2',
        'channel_name': 'c',
        'sender_name': 's',
        'content': 'hi',
        'created_at': epochMillis,
      });

      expect(modelFromMillis.createdAt.millisecondsSinceEpoch, epochMillis);
    });

    test('serializes to JSON accurately', () {
      final model = UserMentionActivityModel(
        id: 'mention-serialize',
        messageId: 'msg-serialize',
        channelId: 'chan-serialize',
        channelName: 'dev-team',
        senderName: 'Dana',
        senderAvatarUrl: 'https://cdn.zedu.test/avatar.jpg',
        content: 'Please review PR #703',
        createdAt: testDate,
      );

      final json = model.toJson();

      expect(json, {
        'id': 'mention-serialize',
        'message_id': 'msg-serialize',
        'channel_id': 'chan-serialize',
        'channel_name': 'dev-team',
        'sender_name': 'Dana',
        'sender_avatar_url': 'https://cdn.zedu.test/avatar.jpg',
        'content': 'Please review PR #703',
        'created_at': testDate.toIso8601String(),
      });
    });

    test('supports equality and hashing', () {
      final modelA = UserMentionActivityModel(
        id: 'eq-1',
        messageId: 'm1',
        channelId: 'c1',
        channelName: 'general',
        senderName: 'Eve',
        content: 'ping',
        createdAt: testDate,
      );
      final modelB = UserMentionActivityModel(
        id: 'eq-1',
        messageId: 'm1',
        channelId: 'c1',
        channelName: 'general',
        senderName: 'Eve',
        content: 'ping',
        createdAt: testDate,
      );
      final modelC = UserMentionActivityModel(
        id: 'eq-2',
        messageId: 'm2',
        channelId: 'c1',
        channelName: 'general',
        senderName: 'Eve',
        content: 'pong',
        createdAt: testDate,
      );

      expect(modelA, equals(modelB));
      expect(modelA.hashCode, equals(modelB.hashCode));
      expect(modelA, isNot(equals(modelC)));
    });
  });
}
