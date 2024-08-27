import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel{
  String name, image,id;
int priority;

CategoriesModel({
  required this.id,
  required this.name,
  required this.image,
  required this.priority
});

// convert to json to object model
 factory CategoriesModel.fromJson(Map<String,dynamic> json,String id){
    return CategoriesModel(
      name: json["name"]??"",
      image: json["image"]??"",
      priority: json["priority"]??0,
      id: id??"",
    );
  }
    // Convert List<QueryDocumentSnapshot> to List<CategoriesModel>
  static List<CategoriesModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((e) => CategoriesModel.fromJson(e.data() as Map<String, dynamic>, e.id)).toList();
  }

}