/// Supported UI languages. The active language is part of the URL (/el, /en).
enum Lang {
  el,
  en;

  String get code => name;

  static Lang fromCode(String? code) =>
      code == 'en' ? Lang.en : Lang.el; // default Greek

  static bool isValid(String? code) => code == 'el' || code == 'en';
}
