import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/cart_model.dart';
import 'package:ecommerce_app/models/products_model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier{
  
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  bool isLoading = true;

  List<CartModel> carts = [];
  List<String> cartUids=[]; 
  List<ProductsModel> products = [];
  int totalCost = 0;
  int totalQuantity = 0;

 CartProvider(){
    readCartData();
  }

   // add product to the cart along with quantity
  void addToCart(CartModel cartModel) {
    DbService().addToCart(cartData: cartModel);
    notifyListeners();
  }

  // stream and read cart data
  void readCartData() {
    isLoading = true;
    _cartSubscription?.cancel();
    _cartSubscription = DbService().readUserCart().listen((snapshot) {
      List<CartModel> cartsData =
          CartModel.fromJsonList(snapshot.docs) as List<CartModel>;

      carts = cartsData;

      cartUids = [];
      for (int i = 0; i < carts.length; i++) {
        cartUids.add(carts[i].productId);
        print("cartUids: ${cartUids[i]}");
      }
      if (carts.length > 0) {
        readCartProducts(cartUids);
      }
      isLoading = false;
      notifyListeners();
    });
  }

  // read cart products
     void readCartProducts(List<String> uids) {
    _productSubscription?.cancel();
    _productSubscription = DbService().searchProducts(uids).listen((snapshot) {
      List<ProductsModel> productsData =
          ProductsModel.fromJsonList(snapshot.docs) as List<ProductsModel>;
      products = productsData;
      isLoading = false;
      addCost(products, carts); // Calculate total cost
      calculateTotalQuantity();
      notifyListeners();
    });
  }
  
  
  // add cost of all products
  void addCost(List<ProductsModel> products, List<CartModel> carts) {
    totalCost = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < carts.length; i++) {
        totalCost += carts[i].quantity * products[i].new_price;
      }
      notifyListeners();
    });
  }

  // calculate total quantity for products
   void calculateTotalQuantity() {
    totalQuantity = 0;
    for (int i = 0; i < carts.length; i++) {
      totalQuantity += carts[i].quantity;
    }
    print("totalQuantity: $totalQuantity");
    notifyListeners();
  }


  // delete product from the cart
  void deleteItem(String productId) {
    DbService().deleteItemFromCart(productId: productId);
    readCartData();
    notifyListeners();
  }

  // decrease the count of product
  void decreaseCount(String productId) async{
   await DbService().decreaseCount(productId: productId);
    notifyListeners();
  }

  void cancelProvider(){
    _cartSubscription?.cancel();
    _productSubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}