import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/models/orders_model.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_admin_app/utils/date_formatter.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Widget statusContainer({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 13)),
    );
  }

  Widget statusIcon(String status) {
    if (status == "PAID") {
      return statusContainer(
          text: "PAID", bgColor: Colors.green, textColor: Colors.white);
    } else if (status == "ON_THE_WAY") {
      return statusContainer(
          text: "ON THE WAY", bgColor: Colors.orange, textColor: Colors.white);
    } else if (status == "DELIVERED") {
      return statusContainer(
          text: "DELIVERED", bgColor: Colors.blue, textColor: Colors.white);
    } else {
      return statusContainer(
          text: "CANCELLED", bgColor: Colors.red, textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders Dashboard",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, value, child) {
          List<OrdersModel> orders = OrdersModel.fromJsonList(value.orders);

          if (orders.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          // Filtering by order status
          int cancelled = orders
              .where((o) => o.status == "CANCELLED")
              .length;
          int paid = orders
              .where((o) => o.status == "PAID")
              .length;
          int onTheWay = orders
              .where((o) => o.status == "ON_THE_WAY")
              .length;
          int delivered = orders
              .where((o) => o.status == "DELIVERED")
              .length;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Summary boxes
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.2,
                        // Controls height
                        children: [
                          summaryBox("Cancelled", cancelled, Colors.red),
                          summaryBox("On the Way", onTheWay, Colors.orange),
                          summaryBox("Paid", paid, Colors.green),
                          summaryBox("Delivered", delivered, Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(thickness: 1),

                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recent Orders",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 2),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/view_order",
                              arguments: order,
                            );
                          },
                          title: Text(
                            "Order by ${order.name}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Ordered ${formatRelativeTime(order.created_at)}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: statusIcon(order.status),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget summaryBox(String label, int value, Color color) {
    return Container(
      height: 70,
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // ✅ replaces .withOpacity(0.15)
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)), // ✅ updated
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}


// Keeps ViewOrder and ModifyOrder classes unchanged
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
        title: const Text("Order Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Delivery Details",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Id : ${args.id}"),
                  Text("Ordered on: ${formatSmartDate(args.created_at)}"),
                  Text("Order by : ${args.name}"),
                  Text("Phone no : ${args.phone}"),
                  Text("Delivery Address : ${args.address}"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Products Summary",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade300),
                ),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.blueGrey),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Product",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Qty",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Total",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  ...args.products.map(
                        (p) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.network(p.image, height: 40, width: 40),
                              const SizedBox(width: 8),
                              Expanded(child: Text(p.name)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                          Text("${p.quantity}", textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("KSh${p.total_price}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Discount : KSh${args.discount}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Total : KSh${args.total}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Status : ${args.status}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 55,
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                child: const Text("Modify Order"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ModifyOrder(order: args),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("Choose what you want to set"),
          ),
          TextButton(
              onPressed: () async {
                await DbService()
                    .updateOrderStatus(docId: widget.order.id, data: {
                  "status": "PAID"
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Order Paid by user")),
          TextButton(
              onPressed: () async {
                await DbService()
                    .updateOrderStatus(docId: widget.order.id, data: {
                  "status": "ON_THE_WAY"
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Order Shipped")),
          TextButton(
              onPressed: () async {
                await DbService()
                    .updateOrderStatus(docId: widget.order.id, data: {
                  "status": "DELIVERED"
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Order Delivered")),
          TextButton(
              onPressed: () async {
                await DbService()
                    .updateOrderStatus(docId: widget.order.id, data: {
                  "status": "CANCELLED"
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Cancel Order")),
        ],
      ),
    );
  }
}
