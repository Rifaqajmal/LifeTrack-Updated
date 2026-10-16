import 'dart:math';

/// Generates a birthday wish message from a small set of templates.
///
/// This is a local templated generator, not a call to an AI/LLM API — the
/// name reflects that honestly. It exists to give the share flow a nicer
/// default message than a single hardcoded line.
class WishGeneratorService {
  WishGeneratorService._();

  static final List<String> _templates = [
    'Happy Birthday {name}! 🎉\nWishing you a year full of happiness, success, and health!',
    'Happy Birthday {name}! 🎂\nMay this new year of your life bring you endless joy and unforgettable memories.',
    'Happy Birthday {name}! 🥳\nHope your day is as amazing as you are — here\'s to another great year ahead!',
    'Happy Birthday {name}! ✨\nSending you warm wishes and lots of love on your special day.',
  ];

  /// Returns a wish for [name]. When [previous] is given, a different
  /// template is chosen so "regenerate" always visibly changes the text.
  static String generate(String name, {String? previous, int? seed}) {
    final random = seed != null ? Random(seed) : Random();
    final options = _templates
        .map((t) => t.replaceAll('{name}', name))
        .where((message) => message != previous)
        .toList();
    if (options.isEmpty) return _templates.first.replaceAll('{name}', name);
    return options[random.nextInt(options.length)];
  }
}
