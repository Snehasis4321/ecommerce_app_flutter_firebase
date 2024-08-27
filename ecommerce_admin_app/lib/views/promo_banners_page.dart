import 'package:ecommerce_admin_app/containers/additional_confirm.dart';
import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/models/promo_banners_model.dart';
import 'package:flutter/material.dart';

class PromoBannersPage extends StatefulWidget {
  const PromoBannersPage({super.key});

  @override
  State<PromoBannersPage> createState() => _PromoBannersPageState();
}

class _PromoBannersPageState extends State<PromoBannersPage> {
   bool _isInitialized = false;
  bool _isPromo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments != null && arguments is Map<String, dynamic>) {

          _isPromo = arguments['promo'] ?? true;
        }
        print("promo $_isPromo");
        _isInitialized = true;
        print("is initialized $_isInitialized");
        setState(() {  
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isPromo?"Promos":"Banners"),),
      body:  _isInitialized? StreamBuilder(stream: DbService().readPromos(_isPromo), 
      builder: (context,snapshot){
        if(snapshot.hasData){
            List<PromoBannersModel> promos = PromoBannersModel.fromJsonList(snapshot.data!.docs) as List<PromoBannersModel>;
            if(promos.isEmpty){
              return Center(child: Text("No ${_isPromo?"Promos":"Banners"} found"),);
            }
            return ListView.builder(itemCount:  promos.length, itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                   showDialog(context: context, builder: (context)=>
        AlertDialog(
          title: Text("What you want to do"),
          content: Text("Delete action cannot be undone"),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
              showDialog(context: context, builder: (context)=>
              AdditionalConfirm(contentText: "Are you sure you want to delete this", onYes: (){
                DbService().deletePromos(id: promos[index].id,isPromo: _isPromo);
                Navigator.pop(context);
              }, onNo: (){
                Navigator.pop(context);
              }));
            }, child: Text("Delete ${_isPromo?"Promo":"Banner"}")),
            TextButton(onPressed: (){
              
            Navigator.pushNamed(context,"/update_promo", arguments: {
                      "promo":_isPromo,
                      "detail":promos[index]
                    });
            }, child: Text("Update ${_isPromo?"Promo":"Banner"}"))
          ],
        )
      );
                  
                },
                leading:  Container(
                    height: 50,
                    width: 50,
                    child: Image.network(promos[index].image),
                  ),
                title: Text(promos[index].title,maxLines: 2,overflow:  TextOverflow.ellipsis,),
                  subtitle: Text(promos[index].category),
                  trailing:  IconButton(icon: Icon(Icons.edit_outlined), onPressed: (){
                    Navigator.pushNamed(context,"/update_promo", arguments: {
                      "promo":_isPromo,
                      "detail":promos[index]
                    });
                  },),
              );
            },);
       
        }

        return Center(child: CircularProgressIndicator(),);
      }):
      SizedBox(),
      floatingActionButton:  FloatingActionButton(onPressed: (){
        Navigator.pushNamed(context,"/update_promo",arguments: {
          "promo" : _isPromo
        });
      },
       child:  Icon(Icons.add),),
    );
  }
}