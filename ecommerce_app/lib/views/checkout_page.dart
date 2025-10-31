import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/contants/payment.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/controllers/mail_service.dart';
import 'package:ecommerce_app/models/orders_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/user_provider.dart';
import 'package:ecommerce_app/services/mpesa_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _couponController = TextEditingController();
  TextEditingController _mpesaPhoneController = TextEditingController();

  int discount = 0;
  String discountText = "";
  bool paymentSuccess = false;
  String? orderId; // ✅ Added orderId here

  // 🔹 Calculate Discount
  void discountCalculator(int disPercent, int totalCost) {
    discount = (disPercent * totalCost) ~/ 100;
    setState(() {});
  }

  // 🔹 Initialize Stripe Payment Sheet
  Future<void> initPaymentSheet(int cost) async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false);
      final data = await createPaymentIntent(
        name: user.name,
        address: user.address,
        amount: (cost * 100).toString(),
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Ecommerce Flutter App',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stripe Error: $e')),
      );
    }
  }

  // 🔹 Handle Stripe Payment
  Future<void> handleStripePayment(int cost) async {
    await initPaymentSheet(cost);
    try {
      await Stripe.instance.presentPaymentSheet();
      await createOrderAfterPayment("Stripe");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stripe payment failed: $e")),
      );
    }
  }

  // 🔹 Handle M-Pesa Payment
  Future<void> handleMpesaPayment(int cost) async {
    try {
      String phone = _mpesaPhoneController.text.trim();
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter your M-Pesa phone number")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Initiating M-Pesa payment...")),
      );

      // ✅ Pre-create the order with PENDING payment before initiating M-Pesa
      if (orderId == null) {
        await createOrderAfterPayment("M-Pesa (Pending)", preCreateOnly: true);
      }

      final response = await MpesaService.initiatePayment(
        phone: phone,
        amount: cost,
        orderId: orderId!,
      );

      if (response.containsKey("ResponseCode") &&
          response["ResponseCode"] == "0") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "STK Push sent! Check your phone to complete payment.")),
        );
        await DbService().updateOrderStatus(
          docId: orderId!,
          data: {"status": "PAID"},
        );
        await afterPaymentSuccess("M-Pesa");
      } else {
        throw Exception("M-Pesa initiation failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("M-Pesa Error: $e")),
      );
    }
  }

  // 🔹 Create Order in Firestore
  Future<void> createOrderAfterPayment(String method,
      {bool preCreateOnly = false}) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);
    User? currentUser = FirebaseAuth.instance.currentUser;

    List products = [];
    for (int i = 0; i < cart.products.length; i++) {
      products.add({
        "id": cart.products[i].id,
        "name": cart.products[i].name,
        "image": cart.products[i].image,
        "single_price": cart.products[i].new_price,
        "total_price": cart.products[i].new_price * cart.carts[i].quantity,
        "quantity": cart.carts[i].quantity
      });
    }

    Map<String, dynamic> orderData = {
      "user_id": currentUser!.uid,
      "name": user.name,
      "email": user.email,
      "address": user.address,
      "phone": user.phone,
      "discount": discount,
      "total": cart.totalCost - discount,
      "products": products,
      "status": method == "Stripe" ? "PAID" : "PENDING",
      "payment_method": method,
      "created_at": DateTime.now().millisecondsSinceEpoch
    };

    // ✅ Create new order and store its ID
    if (orderId == null) {
      final orderRef = await DbService().createOrder(data: orderData);
      orderId = orderRef.id;
    } else if (!preCreateOnly) {
      await DbService().updateOrderStatus(
        docId: orderId!,
        data: {"status": "PAID"},
      );
    }

    if (!preCreateOnly) {
      await afterPaymentSuccess(method);
    }
  }

  // 🔹 Shared logic after successful payment
  Future<void> afterPaymentSuccess(String method) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);

    for (int i = 0; i < cart.products.length; i++) {
      await DbService().reduceQuantity(
        productId: cart.products[i].id,
        quantity: cart.carts[i].quantity,
      );
    }

    await DbService().emptyCart();
    paymentSuccess = true;

    if (paymentSuccess) {
      MailService()
          .sendMailFromGmail(user.email, OrdersModel.fromJson({}, orderId!));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully")),
    );
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout", style: TextStyle(fontSize: 22)),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Consumer<UserProvider>(
          builder: (context, userData, child) =>
              Consumer<CartProvider>(builder: (context, cartData, child) {
                int total = cartData.totalCost - discount;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Delivery Details",
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text(userData.email),
                                Text(userData.address),
                                Text(userData.phone),
                              ],
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/update_profile");
                            },
                            icon: Icon(Icons.edit_outlined),
                          )
                        ]),
                      ),
                      SizedBox(height: 20),
                      Text("Have a coupon?"),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                labelText: "Coupon Code",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              QuerySnapshot querySnapshot = await DbService()
                                  .verifyDiscount(
                                  code:
                                  _couponController.text.toUpperCase());
                              if (querySnapshot.docs.isNotEmpty) {
                                QueryDocumentSnapshot doc =
                                    querySnapshot.docs.first;
                                int percent = doc.get('discount');
                                discountText =
                                "A discount of $percent% has been applied.";
                                discountCalculator(
                                    percent, cartData.totalCost);
                              } else {
                                discountText = "No discount code found";
                              }
                              setState(() {});
                            },
                            child: Text("Apply"),
                          )
                        ],
                      ),
                      if (discountText.isNotEmpty) Text(discountText),
                      Divider(),
                      Text("Total Quantity: ${cartData.totalQuantity}"),
                      Text("Sub Total: ₹ ${cartData.totalCost}"),
                      Text("Extra Discount: - ₹ $discount"),
                      Divider(),
                      Text("Total Payable: ₹ $total",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      SizedBox(height: 20),
                      Text("Pay with M-Pesa"),
                      TextField(
                        controller: _mpesaPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "Enter M-Pesa phone number",
                            filled: true,
                            fillColor: Colors.grey.shade200),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => handleMpesaPayment(total),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: Text("Pay with M-Pesa"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => handleStripePayment(total),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        child: Text("Pay with Card (Stripe)"),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
