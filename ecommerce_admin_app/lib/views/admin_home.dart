import 'package:ecommerce_admin_app/containers/dashboard_text.dart';
import 'package:ecommerce_admin_app/containers/home_button.dart';
import 'package:ecommerce_admin_app/controllers/auth_service.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);

    try {
      Provider.of<AdminProvider>(context, listen: false).cancelProvider();
      await AuthService().logout();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          _isLoggingOut
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Consumer<AdminProvider>(
                builder: (context, value, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DashboardText(keyword: "Total Categories", value: "${value.categories.length}"),
                    DashboardText(keyword: "Total Products", value: "${value.products.length}"),
                    DashboardText(keyword: "Total Orders", value: "${value.totalOrders}"),
                    DashboardText(keyword: "Order Not Shipped yet", value: "${value.orderPendingProcess}"),
                    DashboardText(keyword: "Order Shipped", value: "${value.ordersOnTheWay}"),
                    DashboardText(keyword: "Order Delivered", value: "${value.ordersDelivered}"),
                    DashboardText(keyword: "Order Cancelled", value: "${value.ordersCancelled}"),
                  ],
                ),
              ),
            ),

            // Admin action buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/orders"),
                  name: "Orders",
                ),
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/products"),
                  name: "Products",
                ),
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/promos", arguments: {"promo": true}),
                  name: "Promos",
                ),
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/promos", arguments: {"promo": false}),
                  name: "Banners",
                ),
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/category"),
                  name: "Categories",
                ),
                HomeButton(
                  onTap: () => Navigator.pushNamed(context, "/coupons"),
                  name: "Coupons",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}