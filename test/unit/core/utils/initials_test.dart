import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/core.dart';

void main() {
  group('avatarInitial', () {
    test('returns the upper-cased first letter of a name', () {
      expect(avatarInitial('John'), 'J');
      expect(avatarInitial('ada okafor'), 'A');
    });

    test('ignores leading and trailing whitespace', () {
      expect(avatarInitial(' John'), 'J');
      expect(avatarInitial('\t\n ada  '), 'A');
    });

    test('falls back to ? for null, empty or whitespace-only names', () {
      expect(avatarInitial(null), '?');
      expect(avatarInitial(''), '?');
      expect(avatarInitial('   '), '?');
      expect(avatarInitial('\t\n'), '?');
    });

    test('uses the given fallback when the name is blank', () {
      expect(avatarInitial('', fallback: 'Z'), 'Z');
      expect(avatarInitial(' ', fallback: avatarInitial('mo@zedu.chat')), 'M');
      expect(avatarInitial('Ada', fallback: 'Z'), 'A');
    });

    test('keeps an emoji or accented letter whole', () {
      expect(avatarInitial('😀 Smile'), '😀');
      expect(avatarInitial('👨‍👩‍👧 Family'), '👨‍👩‍👧');
      expect(avatarInitial('émile'), 'É');
    });

    test('handles very long names', () {
      expect(avatarInitial('x' * 10000), 'X');
    });
  });
}
