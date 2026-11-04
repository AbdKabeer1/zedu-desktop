import 'package:zedu/core/core.dart';

/// Inline Markdown used by DM messages: `*italic*`, `**bold**`,
/// `~~strike~~` and `` `code` ``.
///
/// Italic is tried first and may contain `**bold**` pairs, so text that was
/// made bold and italic (`***word***`, from either toolbar order) is read as
/// italic around bold instead of bold around a stray `*`. A lone `**` is the
/// empty italic the toolbar inserts with no selection.
final _inlineMarkdown = RegExp(
  r'(?<!\*)\*(?<italic>(?:\*\*.+?\*\*|[^*])+?)\*(?!\*)'
  r'|\*\*(?<bold>.*?)\*\*(?!\*)'
  r'|(?<!\*)\*\*(?!\*)'
  r'|~~(?<strike>.*?)~~'
  r'|`(?<code>.*?)`',
  dotAll: true,
);

/// Builds a span for [text] with inline Markdown applied on top of [style].
///
/// Formatting nests, so `~~**word**~~` is struck through and bold. Inline
/// code stays literal. With [keepMarkers] the markers stay in the span but
/// are invisible, so the span's text matches [text] (needed by the composer,
/// whose cursor offsets index into the raw text); otherwise they are dropped.
TextSpan buildInlineMarkdownSpan(
  String text,
  TextStyle style, {
  bool keepMarkers = false,
}) {
  if (text.isEmpty) return TextSpan(style: style, text: '');
  return TextSpan(
    style: style,
    children: _inlineSpans(text, style, keepMarkers),
  );
}

List<InlineSpan> _inlineSpans(String text, TextStyle style, bool keepMarkers) {
  final spans = <InlineSpan>[];
  final hiddenStyle = style.copyWith(color: Colors.transparent, fontSize: 0.01);

  void addToken(String marker, String inner, TextStyle innerStyle, bool nest) {
    if (keepMarkers) spans.add(TextSpan(text: marker, style: hiddenStyle));
    if (inner.isNotEmpty) {
      spans.add(
        nest
            ? TextSpan(children: _inlineSpans(inner, innerStyle, keepMarkers))
            : TextSpan(text: inner, style: innerStyle),
      );
    }
    if (keepMarkers) spans.add(TextSpan(text: marker, style: hiddenStyle));
  }

  var lastEnd = 0;
  for (final match in _inlineMarkdown.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(
        TextSpan(text: text.substring(lastEnd, match.start), style: style),
      );
    }

    final italic = match.namedGroup('italic');
    final bold = match.namedGroup('bold');
    final strike = match.namedGroup('strike');
    final code = match.namedGroup('code');
    if (italic != null) {
      addToken('*', italic, style.copyWith(fontStyle: FontStyle.italic), true);
    } else if (bold != null) {
      addToken('**', bold, style.copyWith(fontWeight: FontWeight.bold), true);
    } else if (strike != null) {
      addToken(
        '~~',
        strike,
        style.copyWith(decoration: TextDecoration.lineThrough),
        true,
      );
    } else if (code != null) {
      addToken(
        '`',
        code,
        style.copyWith(
          fontFamily: 'monospace',
          backgroundColor: const Color(0x1A6458F5),
          color: const Color(0xFF6458F5),
        ),
        false,
      );
    } else if (keepMarkers) {
      // Empty italic (`**`): nothing to show but the hidden markers.
      spans.add(TextSpan(text: match.group(0), style: hiddenStyle));
    }

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: style));
  }
  return spans;
}
