import 'package:ecommerce_admin_app/containers/additional_confirm.dart';
import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/models/coupon_model.dart';
import 'package:flutter/material.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Coupons"),
      ),
      body: StreamBuilder(
        stream: DbService().readCouponCode(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CouponModel> coupons =
                CouponModel.fromJsonList(snapshot.data!.docs)
                    as List<CouponModel>;

            if (coupons.isEmpty) {
              return Center(
                child: Text("No coupons found"),
              );
            } else {
              return ListView.builder(
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("What you want to do"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AdditionalConfirm(
                                                  contentText:
                                                      "Delete cannot be undone",
                                                  onNo: () {
                                                    Navigator.pop(context);
                                                  },
                                                  onYes: () {
                                                    DbService()
                                                        .deleteCouponCode(
                                                            docId:
                                                                coupons[index]
                                                                    .id);
                                                    Navigator.pop(context);
                                                  },
                                                ));
                                      },
                                      child: Text("Delete Coupon")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) => ModifyCoupon(
                                                id: coupons[index].id,
                                                code: coupons[index].code,
                                                desc: coupons[index].desc,
                                                discount:
                                                    coupons[index].discount));
                                      },
                                      child: Text("Update Coupon")),
                                ],
                              ));
                    },
                    title: Text(coupons[index].code),
                    subtitle: Text(coupons[index].desc),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_outlined),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => ModifyCoupon(
                                id: coupons[index].id,
                                code: coupons[index].code,
                                desc: coupons[index].desc,
                                discount: coupons[index].discount));
                      },
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) =>
                  ModifyCoupon(id: "", code: "", desc: "", discount: 0));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ModifyCoupon extends StatefulWidget {
  final String id, code, desc;
  final int discount;
  const ModifyCoupon(
      {super.key,
      required this.id,
      required this.code,
      required this.desc,
      required this.discount});

  @override
  State<ModifyCoupon> createState() => _ModifyCouponState();
}

class _ModifyCouponState extends State<ModifyCoupon> {
  final formKey = GlobalKey<FormState>();
  TextEditingController descController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController disPercentController = TextEditingController();

  @override
  void initState() {
    descController.text = widget.desc;
    codeController.text = widget.code;
    disPercentController.text = widget.discount.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id.isNotEmpty ? "Update Coupon" : "Add Coupon"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("All will be converted to Uppercase"),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: codeController,
                validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                decoration: InputDecoration(
                    hintText: "Coupon Code",
                    label: Text("Coupon Code"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: descController,
                validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                decoration: InputDecoration(
                    hintText: "Description",
                    label: Text("Description"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: disPercentController,
                validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                decoration: InputDecoration(
                    hintText: "Discount % ",
                    label: Text("Discount % "),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel")),
        TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                var data = {
                  "code": codeController.text.toUpperCase(),
                  "desc": descController.text,
                  "discount": int.parse(disPercentController.text)
                };

                if (widget.id.isNotEmpty) {
                  DbService().updateCouponCode(docId: widget.id, data: data);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Coupon Code updated.")));
                } else {
                  DbService().createCouponCode(data: data);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Coupon Code added.")));
                }
                Navigator.pop(context);
              }
            },
            child: Text(widget.id.isNotEmpty ? "Update Coupon" : "Add Coupon")),
      ],
    );
  }
}
