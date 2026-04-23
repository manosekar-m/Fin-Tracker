class RoughPlanModel {
  final String id;
  final String title;
  final String notes;
  final double budget;
  final DateTime createdAt;

  RoughPlanModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.budget,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'budget': budget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RoughPlanModel.fromMap(Map<String, dynamic> map) {
    return RoughPlanModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get totalSpent {
    if (notes.isEmpty) return 0.0;
    // Look for numbers in the notes. We'll try to find numbers that appear at the end of lines
    // or are clearly intended as amounts (e.g., "food 200", "taxi 50").
    final lines = notes.split('\n');
    double total = 0.0;
    final amountRegex = RegExp(r'(\d+(?:\.\d{1,2})?)$'); // Matches number at the end of a line
    
    for (var line in lines) {
      final match = amountRegex.firstMatch(line.trim());
      if (match != null) {
        total += double.tryParse(match.group(1)!) ?? 0.0;
      }
    }
    return total;
  }

  double get remainingBudget => budget - totalSpent;
}
