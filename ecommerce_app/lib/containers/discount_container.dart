import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/models/coupon_model.dart';
import 'package:flutter/material.dart';

class DiscountContainer extends StatefulWidget {
  const DiscountContainer({super.key});

  @override
  State<DiscountContainer> createState() => _DiscountContainerState();
}

class _DiscountContainerState extends State<DiscountContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: DbService().readDiscounts(), builder: (context,snapshot){
      if(snapshot.hasData){
        List<CouponModel> discounts= CouponModel.fromJsonList(snapshot.data!.docs) as List<CouponModel>;

        if(discounts.isEmpty){
          return SizedBox();
        }
        else{
          return GestureDetector(
            onTap: ()=> Navigator.pushNamed(context, "/discount"),
            child: Container(
              width:  double.infinity,
               padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  margin:  EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration:   BoxDecoration(
                  color: Colors.blue.shade100,
                    borderRadius:  BorderRadius.circular(20),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start
                ,children: [
                Text("Use coupon : ${discounts[0].code}",style:  TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.blue.shade900)),
                Text(discounts[0].desc,style:  TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.blue.shade900))
              ],),
            ),
          );
          
        }

      }
      else{
        return SizedBox();
      }
    });
  }
}