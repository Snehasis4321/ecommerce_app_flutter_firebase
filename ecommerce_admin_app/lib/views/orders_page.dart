
import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/models/orders_model.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  totalQuantityCalculator(List<OrderProductModel> products) {
    int qty = 0;
    products.map((e) => qty += e.quantity).toList();
    return qty;
  }

  Widget statusIcon(String status) {
    if (status == "PAID") {
      return statusContainer(
          text: "PAID", bgColor: Colors.lightGreen, textColor: Colors.white);
    }
    if (status == "ON_THE_WAY") {
      return statusContainer(
          text: "ON THE WAY", bgColor: Colors.yellow, textColor: Colors.black);
    } else if (status == "DELIVERED") {
      return statusContainer(
          text: "DELIVERED",
          bgColor: Colors.green.shade700,
          textColor: Colors.white);
    } else {
      return statusContainer(
          text: "CANCELED", bgColor: Colors.red, textColor: Colors.white);
    }
  }

  Widget statusContainer(
      {required String text,
      required Color bgColor,
      required Color textColor}) {
    return Container(
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      color: bgColor,
      padding: EdgeInsets.all(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orders",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body:Consumer<AdminProvider>(
        builder: (context, value, child) {
           List<OrdersModel> orders =
                OrdersModel.fromJsonList(value.orders)
                    as List<OrdersModel>;

            if (orders.isEmpty) {
              return Center(
                child: Text("No orders found"),
              );
            } else {
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/view_order",
                          arguments: orders[index]);
                    },
                    title: Text(
                        "Order by ${orders[index].name} "),
                    subtitle: Text(
                        "Ordered on ${DateTime.fromMillisecondsSinceEpoch(orders[index].created_at).toString()}"),
                    trailing: statusIcon(orders[index].status),
                  );
                },
              );
            }
        
        },
      ),
    );
  }
}

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Summary"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Delivery Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Id : ${args.id}"),
                    Text(
                        "Order On : ${DateTime.fromMillisecondsSinceEpoch(args.created_at).toString()}"),
                    Text("Order by : ${args.name}"),
                    Text("Phone no : ${args.phone}"),
                    Text("Delivery Address : ${args.address}"),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: args.products
                    .map((e) => Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(e.image),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(child: Text(e.name)),
                                ],
                              ),
                              Text(
                                "₹${e.single_price.toString()} x ${e.quantity.toString()} quantity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "₹${e.total_price.toString()}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discount : ₹${args.discount}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      "Total : ₹${args.total}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      "Status : ${args.status}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
          
              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width * .9,
                child: ElevatedButton(
                  child: Text("Modify Order"),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => ModifyOrder(
                              order: args,
                            ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ModifyOrder extends StatefulWidget {
  final OrdersModel order;
  const ModifyOrder({super.key, required this.order});

  @override
  State<ModifyOrder> createState() => _ModifyOrderState();
}

class _ModifyOrderState extends State<ModifyOrder> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Modify this order"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("Chosse want you want set"),
          ),
          TextButton(
              onPressed: () async{

              await  DbService().updateOrderStatus(docId: widget.order.id, data: 
                {
                  "status" : "PAID"
                });
                Navigator.pop(context);
                Navigator.pop(context);
               
              },
              child: Text("Order Paid by user")),
          TextButton(
              onPressed: () async{

              await  DbService().updateOrderStatus(docId: widget.order.id, data: 
                {
                  "status" : "ON_THE_WAY"
                });
                Navigator.pop(context);
                Navigator.pop(context);
               
              },
              child: Text("Order Shipped")),
          TextButton(
              onPressed: ()async {
                 await  DbService().updateOrderStatus(docId: widget.order.id, data: 
                {
                  "status" : "DELIVERED"
                });
                Navigator.pop(context);
                Navigator.pop(context);
               
              },
              child: Text("Order Delivered")),
          TextButton(
              onPressed: () async{
                await  DbService().updateOrderStatus(docId: widget.order.id, data: 
                {
                  "status" : "CANCELLED"
                });
                Navigator.pop(context);
                Navigator.pop(context);
               
              },
              child: Text("Cancel Order")),
        ],
      ),
    );
  }
}
