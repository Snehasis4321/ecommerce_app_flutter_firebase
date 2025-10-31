import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  bool isLoading = true;
  List<CartModel> carts = [];
  List<String> cartUids = [];
  List<ProductsModel> products = [];
  int totalCost = 0;
  int totalQuantity = 0;

  CartProvider() {
    readCartData();
  }

  void addToCart(CartModel cartModel) {
    DbService().addToCart(cartData: cartModel);
    notifyListeners();
  }

  void readCartData() {
    isLoading = true;
    _cartSubscription?.cancel();

    _cartSubscription = DbService().readUserCart().listen((snapshot) {
      List<CartModel> cartsData = CartModel.fromJsonList(snapshot.docs);
      carts = cartsData;

      cartUids = carts.map((e) => e.productId).toList();

      if (carts.isNotEmpty) {
        readCartProducts(cartUids);
      }

      isLoading = false;
      notifyListeners();
    });
  }

  void readCartProducts(List<String> uids) {
    _productSubscription?.cancel();

    _productSubscription = DbService().searchProducts(uids).listen((snapshot) {
      List<ProductsModel> productsData = ProductsModel.fromJsonList(snapshot.docs);
      products = productsData;

      addCost(products, carts);
      calculateTotalQuantity();
      isLoading = false;
      notifyListeners();
    });
  }

  void addCost(List<ProductsModel> products, List<CartModel> carts) {
    totalCost = 0;
    for (int i = 0; i < carts.length; i++) {
      totalCost += carts[i].quantity * products[i].new_price;
    }
    notifyListeners();
  }

  void calculateTotalQuantity() {
    totalQuantity = carts.fold(0, (sum, item) => sum + item.quantity);
    notifyListeners();
  }

  void deleteItem(String productId) {
    DbService().deleteItemFromCart(productId: productId);
    notifyListeners();
  }

  void decreaseCount(String productId) {
    DbService().decreaseCount(productId: productId);
    notifyListeners();
  }

  Future<void> refreshCart() async {
    readCartData();
  }

  void cancelProvider() {
    _cartSubscription?.cancel();
    _productSubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}
