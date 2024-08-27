import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel{
    String id;
  String code;
  int discount;
  String desc;

CouponModel({required this.id,required this.code,required this.discount,required this.desc});

  // to convert the json to object model
  factory CouponModel.fromJson(Map<String,dynamic> json,String id){
    return CouponModel(
      id: id??"", 
      code: json["code"]??"",
      discount: json["discount"]??0,
      desc: json["desc"]??""

    );
  }

  // Convert List<QueryDocumentSnapshot> to List<CouponModel>
   static List<CouponModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((e) => CouponModel.fromJson(e.data() as Map<String, dynamic>, e.id)).toList();
  }
}
