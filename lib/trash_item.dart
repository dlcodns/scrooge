class TrashItem {
  final int id;
  final String whoUse;
  final DateTime deletedDate;
  final DateTime usedDate;

  TrashItem({
    required this.id,
    required this.whoUse,
    required this.deletedDate,
    required this.usedDate,
  });

  factory TrashItem.fromJson(Map<String, dynamic> json) {
    return TrashItem(
      id: json['id'] as int,
      whoUse: json['whoUse'] ?? '',
      deletedDate: DateTime.parse(json['deletedDate']),
      usedDate: DateTime.parse(json['usedDate']),
    );
  }
}
