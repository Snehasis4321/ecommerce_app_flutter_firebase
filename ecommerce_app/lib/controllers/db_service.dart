import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbService {
  final User? user = FirebaseAuth.instance.currentUser;

  // ============================
  // 🔹 USER DATA
  // ============================

  Future<void> saveUserData({
    required String name,
    required String email,
  }) async {
    final data = {"name": name, "email": email, "address": "", "phone": ""};
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .set(data);
  }

  Future<void> updateUserData({required Map<String, dynamic> extraData}) async {
    final uid = user!.uid;
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(uid)
        .update(extraData);
  }

  Stream<DocumentSnapshot> readUserData() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .snapshots();
  }

  // ============================
  // 🔹 PROMOS & BANNERS
  // ============================

  Stream<QuerySnapshot> readPromos() {
    return FirebaseFirestore.instance.collection("shop_promos").snapshots();
  }

  Stream<QuerySnapshot> readBanners() {
    return FirebaseFirestore.instance.collection("shop_banners").snapshots();
  }

  // ============================
  // 🔹 DISCOUNTS
  // ============================

  Stream<QuerySnapshot> readDiscounts() {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .orderBy("discount", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> verifyDiscount({required String code}) {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .where("code", isEqualTo: code)
        .get();
  }

  // ============================
  // 🔹 CATEGORIES & PRODUCTS
  // ============================

  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> readProducts(String category) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where("category", isEqualTo: category.toLowerCase())
        .snapshots();
  }

  Stream<QuerySnapshot> searchProducts(List<String> docIds) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where(FieldPath.documentId, whereIn: docIds)
        .snapshots();
  }

  Future<void> reduceQuantity({
    required String productId,
    required int quantity,
  }) async {
    final productRef =
    FirebaseFirestore.instance.collection("shop_products").doc(productId);
    final doc = await productRef.get();
    if (doc.exists) {
      int currentStock = doc["maxQuantity"];
      int newStock = currentStock - quantity;
      await productRef.update({"maxQuantity": newStock});
    }
  }

  // ============================
  // 🔹 CART
  // ============================

  Stream<QuerySnapshot> readUserCart() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .snapshots();
  }

  Future<void> addToCart({required CartModel cartData}) async {
    try {
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("cart")
          .doc(cartData.productId)
          .update({
        "product_id": cartData.productId,
        "quantity": FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      if (e.code == "not-found") {
        await FirebaseFirestore.instance
            .collection("shop_users")
            .doc(user!.uid)
            .collection("cart")
            .doc(cartData.productId)
            .set({
          "product_id": cartData.productId,
          "quantity": 1,
        });
      }
    }
  }

  Future<void> deleteItemFromCart({required String productId}) async {
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .delete();
  }

  Future<void> decreaseCount({required String productId}) async {
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .update({"quantity": FieldValue.increment(-1)});
  }

  Future<void> emptyCart() async {
    final cartRef = FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart");

    final snapshot = await cartRef.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ============================
  // 🔹 ORDERS
  // ============================

  Future<DocumentReference> createOrder({required Map<String, dynamic> data}) async {
    return await FirebaseFirestore.instance.collection("shop_orders").add(data);
  }

  Future<void> updateOrderStatus({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }

  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .where("user_id", isEqualTo: user!.uid)
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  // ============================
  // 🔹 ADMIN HELPERS
  // ============================

  Stream<QuerySnapshot> readAllOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created_at", descending: true)
        .snapshots();
  }
}
