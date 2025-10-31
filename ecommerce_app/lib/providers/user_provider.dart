import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  String name = "User";
  String email = "";
  String address = "";
  String phone = "";

  UserProvider() {
    loadUserData();
  }

  /// 🔹 Listen to Firestore changes in real-time
  void loadUserData() {
    _userSubscription?.cancel();
    _userSubscription = DbService().readUserData().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final UserModel data =
        UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
        name = data.name;
        email = data.email;
        address = data.address;
        phone = data.phone;
        notifyListeners();
      }
    });
  }

  /// 🔹 Manually update provider fields (use after local updates)
  void updateUserData(Map<String, dynamic> updatedData) {
    if (updatedData.containsKey("name")) name = updatedData["name"];
    if (updatedData.containsKey("email")) email = updatedData["email"];
    if (updatedData.containsKey("address")) address = updatedData["address"];
    if (updatedData.containsKey("phone")) phone = updatedData["phone"];
    notifyListeners();
  }

  /// 🔹 Cancel Firestore listener
  void cancelProvider() {
    _userSubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}
