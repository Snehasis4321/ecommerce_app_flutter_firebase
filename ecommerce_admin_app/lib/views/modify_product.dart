import 'dart:io';

import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/controllers/storage_service.dart';
import 'package:ecommerce_admin_app/models/products_model.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ModifyProduct extends StatefulWidget {
  const ModifyProduct({super.key});

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  late String productId = "";
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController newPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  late XFile? image = null;

  // function to pick image using image picker
  Future<void> pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? res = await  StorageService().uploadImage(image!.path,context);
      setState(() {
        if (res != null) {
          imageController.text = res;
          print("set image url ${res} : ${imageController.text}");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Image uploaded successfully")));
        }
      });
    }
  }

  // set the data from arguments
  setData(ProductsModel data){
    productId=data.id;
    nameController.text= data.name;
    oldPriceController.text= data.old_price.toString();
    newPriceController.text= data.new_price.toString();
    quantityController.text=data.maxQuantity.toString();
    categoryController.text= data.category;
    descController.text= data.description;
    imageController.text= data.image;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments= ModalRoute.of(context)!.settings.arguments ;
    if(arguments != null && arguments is ProductsModel){
      setData(arguments);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(productId.isNotEmpty? "Update Product": "Add Product"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                      hintText: "Product Name",
                      label: Text("Product Name"),
                      fillColor: Colors.deepPurple.shade50,
                      filled: true),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: oldPriceController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Original Price",
                    label: Text("Original Price"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: newPriceController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                    hintText: "Sell Price",
                    label: Text("Sell Price"),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: quantityController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                      hintText: "Quantity Left",
                      label: Text("Quantity Left"),
                      fillColor: Colors.deepPurple.shade50,
                      filled: true),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: categoryController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: "Category",
                      label: Text("Category"),
                      fillColor: Colors.deepPurple.shade50,
                      filled: true),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Select Category :"),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Consumer<AdminProvider>(
                                      builder: (context, value, child) =>
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: value.categories
                                                  .map((e) => TextButton(
                                                      onPressed: () {
                                                        categoryController
                                                            .text = e["name"];
                                                        setState(() {});
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(e["name"])))
                                                  .toList(),
                                            ),
                                          ))
                                ],
                              ),
                            ));
                  },
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
                  maxLines: 8,
                ),
                SizedBox(height: 10,),
                image == null
                  ? imageController.text.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.all(20),
                          height: 100,
                          width: double.infinity,
                          color: Colors.deepPurple.shade50,
                          child: Image.network(
                            imageController.text,
                            fit: BoxFit.contain,
                          ))
                      : SizedBox()
                  : Container(
                      margin: EdgeInsets.all(20),
                      height: 200,
                      width: double.infinity,
                      color: Colors.deepPurple.shade50,
                      child: Image.file(
                        File(image!.path),
                        fit: BoxFit.contain,
                      )),
                    ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Text("Pick Image")),
                  SizedBox(height: 10,),
                 TextFormField(
                  controller: imageController,
                  validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                  decoration: InputDecoration(
                      hintText: "Image Link",
                      label: Text("Image Link"),
                      fillColor: Colors.deepPurple.shade50,
                      filled: true),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: 60,
                  width:  double.infinity,
                  child: ElevatedButton(onPressed: (){
                    if(formKey.currentState!.validate()){
                      Map<String, dynamic> data = {
                  "name": nameController.text,
                  "old_price": int.parse(oldPriceController.text),
                  "new_price": int.parse(newPriceController.text),
                  "quantity": int.parse(quantityController.text),
                  "category": categoryController.text,
                  "desc": descController.text,
                  "image": imageController.text
                };

                if(productId.isNotEmpty){
                  DbService().updateProduct(docId: productId, data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product Updated")));
                }
                else{
                  DbService().createProduct( data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product Added")));
                }
                    }
                  }, child: Text(productId.isNotEmpty?"Update Product" : "Add Product")))
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
