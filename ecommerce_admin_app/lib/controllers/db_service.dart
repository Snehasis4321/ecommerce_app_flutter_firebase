import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
// CATEGORIES
// read categories from database
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  // create new category
  Future createCategories({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_categories").add(data);
  }

  // update category
  Future updateCategories(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .update(data);
  }

  // delete category
  Future deleteCategories({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .delete();
  }

  // PRODUCTS
  // read products from database
  Stream<QuerySnapshot> readProducts() {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots();
  }

  // create a new product
  Future createProduct({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_products").add(data);
  }

  // update the product
  Future updateProduct(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .update(data);
  }

  // delete the product
  Future deleteProduct({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .delete();
  }

  // PROMOS & BANNERS
  // read promos from database
  Stream<QuerySnapshot> readPromos(bool isPromo) {
    print("reading $isPromo");
    return FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .snapshots();
  }

  // create new promo or banner
  Future createPromos(
      {required Map<String, dynamic> data, required bool isPromo}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .add(data);
  }

  // update promo or banner
  Future updatePromos(
      {required Map<String, dynamic> data,
      required bool isPromo,
      required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .update(data);
  }

  // delete promo or banner
  Future deletePromos({required bool isPromo, required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .delete();
  }

  // DISCOUNT AND COUPON CODE
  // read coupon code from database
  Stream<QuerySnapshot> readCouponCode() {
    return FirebaseFirestore.instance.collection("shop_coupons").snapshots();
  }

  // create new coupon code
  Future createCouponCode({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_coupons").add(data);
  }

  // update coupon code
  Future updateCouponCode(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .update(data);
  }

  // delete coupon code
  Future deleteCouponCode({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .delete();
  }

  // ORDERS
  // read all the orders
  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

    // update the status of order
  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }
}
