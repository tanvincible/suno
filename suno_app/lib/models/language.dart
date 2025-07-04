enum Language {
  english('en', 'English'),
  spanish('es', 'Spanish'),
  french('fr', 'French'),
  german('de', 'German'),
  hindi('hi', 'Hindi'); // Example for a common Indian language

  final String code;
  final String displayName;

  const Language(this.code, this.displayName);
}
