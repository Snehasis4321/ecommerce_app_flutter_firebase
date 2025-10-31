import 'package:ecommerce_app/containers/additional_confirm.dart';
import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/orders_model.dart';
import 'package:ecommerce_app/utils/date_formatter.dart'; // ✅ import this
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int totalQuantityCalculator(List<OrderProductModel> products) {
    int qty = 0;
    for (var e in products) {
      qty += e.quantity;
    }
    return qty;
  }

  Widget statusIcon(String status) {
    if (status == "PAID") {
      return statusContainer(
        text: "PAID",
        bgColor: Colors.lightGreen,
        textColor: Colors.white,
      );
    } else if (status == "ON_THE_WAY") {
      return statusContainer(
        text: "ON THE WAY",
        bgColor: Colors.yellow,
        textColor: Colors.black,
      );
    } else if (status == "DELIVERED") {
      return statusContainer(
        text: "DELIVERED",
        bgColor: Colors.green.shade700,
        textColor: Colors.white,
      );
    } else {
      return statusContainer(
        text: "CANCELLED",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget statusContainer({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: bgColor,
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: StreamBuilder(
        stream: DbService().readOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<OrdersModel> orders =
            OrdersModel.fromJsonList(snapshot.data!.docs);
            if (orders.isEmpty) {
              return const Center(child: Text("No orders found"));
            } else {
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      "/view_order",
                      arguments: order,
                    ),
                    title: Text(
                      "${totalQuantityCalculator(order.products)} Items Worth KSh ${order.total}",
                    ),
                    subtitle: Text(
                      "Ordered on ${formatSmartDate(order.created_at)}", // ✅ using our formatter
                    ),
                    trailing: statusIcon(order.status),
                  );
                },
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ViewOrder extends StatelessWidget {
  const ViewOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Delivery Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Id: ${args.id}"),
                  Text("Ordered on: ${formatSmartDate(args.created_at)}"),
                  Text("Order by: ${args.name}"),
                  Text("Phone no: ${args.phone}"),
                  Text("Delivery Address: ${args.address}"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: args.products.map((e) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.network(e.image),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.name)),
                        ],
                      ),
                      Text(
                        "KSh ${e.single_price} x ${e.quantity} quantity",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "KSh ${e.total_price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discount: KSh ${args.discount}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    "Total: KSh ${args.total}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    "Status: ${args.status}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (args.status == "PAID" || args.status == "ON_THE_WAY")
              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width * .9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ModifyOrder(order: args),
                    );
                  },
                  child: const Text("Modify Order"),
                ),
              ),
          ],
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
      title: const Text("Modify this order"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choose what you want to do"),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AdditionalConfirm(
                  contentText:
                  "After canceling this cannot be changed — you’ll need to order again.",
                  onYes: () async {
                    await DbService().updateOrderStatus(
                      docId: widget.order.id,
                      data: {"status": "CANCELLED"},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order Updated")),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  onNo: () => Navigator.pop(context),
                ),
              );
            },
            child: const Text("Cancel Order"),
          ),
        ],
      ),
    );
  }
}
