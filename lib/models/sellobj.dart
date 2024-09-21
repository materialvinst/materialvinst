class SellObj {
  final int id;
  final String name;
  final String date;
  final String place;
  final String seller;

  SellObj(
      {required this.id,
      required this.name,
      required this.date,
      required this.place,
      required this.seller});

  factory SellObj.fromJson(Map<String, dynamic> json) {
    return SellObj(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      place: json['place'],
      seller: json['seller'],
    );
  }
}
