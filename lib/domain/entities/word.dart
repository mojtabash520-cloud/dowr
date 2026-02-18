class Word {
  final String text;
  final List<String> forbidden;

  Word({required this.text, this.forbidden = const []});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'],
      forbidden: List<String>.from(json['forbidden'] ?? []),
    );
  }
}
