class TarotCard {
  const TarotCard({
    required this.name,
    required this.symbol,
    required this.meaning,
    required this.catMessage,
    this.imageAsset,
  });

  final String name;
  final String symbol;
  final String meaning;
  final String catMessage;
  final String? imageAsset;
}
