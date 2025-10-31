import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final int old_price;
  final int new_price;
  final String category;
  final int maxQuantity;

  ProductsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.old_price,
    required this.new_price,
    required this.category,
    required this.maxQuantity,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductsModel(
      id: id,
      name: json["name"] ?? "",
      description: json["desc"] ?? "No description",
      image: json["image"] ?? "",
      new_price: (json["new_price"] ?? 0).toInt(),
      old_price: (json["old_price"] ?? 0).toInt(),
      category: json["category"] ?? "",
      maxQuantity: (json["quantity"] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "desc": description,
    "image": image,
    "new_price": new_price,
    "old_price": old_price,
    "category": category,
    "quantity": maxQuantity,
  };

  static List<ProductsModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((doc) =>
        ProductsModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
