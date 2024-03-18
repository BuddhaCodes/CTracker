enum Effort { mucho, medio, poco }

extension EfforExtension on Effort {
  String get name {
    switch (this) {
      case Effort.mucho:
        return '\u{26A1} I will have to summon the powers of Odin \u{26A1}';
      case Effort.medio:
        return '\u{1F4AA} I can handle it with a bit of effort \u{1F4AA}';
      case Effort.poco:
        return 'Bring 300 \u{1F680} \u{1F680} \u{1F680} !!!';
      default:
        return 'Alert';
    }
  }
}
