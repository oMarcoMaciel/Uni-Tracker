import 'package:characters/characters.dart';

String formatFirstAndLastName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return trimmed;

  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((p) => p.trim().isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first;

  return '${parts.first} ${parts.last}';
}

String limitCharacters(String text, int maxChars, {String ellipsis = '…'}) {
  if (maxChars <= 0) return '';

  final trimmed = text.trim();
  final textChars = trimmed.characters;

  if (textChars.length <= maxChars) return trimmed;

  final ellipsisChars = ellipsis.characters;
  if (ellipsisChars.length >= maxChars) {
    return ellipsisChars.take(maxChars).toString();
  }

  final takeCount = maxChars - ellipsisChars.length;
  return '${textChars.take(takeCount)}$ellipsis';
}
