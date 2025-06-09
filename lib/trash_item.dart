class TrashItem {
  final int id;
  final String gifticonId;
  final String gifticonName;  
  final String whoUse;
  final DateTime deletedDate;
  final DateTime usedDate;

  TrashItem({
    required this.id,
    required this.gifticonId,
    required this.gifticonName,
    required this.whoUse,
    required this.deletedDate,
    required this.usedDate,
  });

  factory TrashItem.fromJson(Map<String, dynamic> json) {
    return TrashItem(
      id: json['id'],
      gifticonId: json['gifticonId'],
      gifticonName: json['gifticonName'],   
      whoUse: json['whoUse'],
      deletedDate: DateTime.parse(json['deletedDate']),
      usedDate: DateTime.parse(json['usedDate']),
    );
  }
}
