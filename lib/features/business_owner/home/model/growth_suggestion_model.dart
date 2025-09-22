class GrowthSuggestion {
  final String suggestionTitle;
  final String shortDescription;
  final String category; // "discount" | "operational" | "marketing"

  GrowthSuggestion({
    required this.suggestionTitle,
    required this.shortDescription,
    required this.category,
  });

  factory GrowthSuggestion.fromJson(Map<String, dynamic> j) => GrowthSuggestion(
    suggestionTitle: (j['suggestion_title'] ?? '').toString(),
    shortDescription: (j['short_description'] ?? '').toString(),
    category: (j['category'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'suggestion_title': suggestionTitle,
    'short_description': shortDescription,
    'category': category,
  };
}
