class Item {
  final String name;
  final String from;
  final String destination;
  final String weight;
  final String imagePath;
  bool isSelected;

  Item({
    required this.name,
    required this.from,
    required this.destination,
    required this.weight,
    required this.imagePath,
    this.isSelected = false,
  });
}
