class ItemModel {
  dynamic? id;
  dynamic? name;
  int? price;

  ItemModel({this.id, this.name, this.price});

  ItemModel.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
