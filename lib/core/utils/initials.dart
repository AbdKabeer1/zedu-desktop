import 'package:zedu/core/core.dart';

/// The upper-cased first letter of [name] for an avatar, e.g. `J` for
/// `' john'`.
///
/// Surrounding whitespace is ignored and the first user-perceived character
/// is taken, so an emoji or accented letter is never split in half. A null,
/// empty or whitespace-only [name] returns [fallback] instead of throwing.
String avatarInitial(String? name, {String fallback = '?'}) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return fallback;
  return trimmed.characters.first.toUpperCase();
}
