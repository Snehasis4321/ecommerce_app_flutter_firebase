
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import  'package:http/http.dart' as http;

Future createPaymentIntent({required String name,
  required String address,

  required String amount}) async{

  final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
  final secretKey=dotenv.env["STRIPE_SECRET_KEY"]!;
  final body={
    'amount': amount,
    'currency': "inr",
    'automatic_payment_methods[enabled]': 'true',
    'description': "Shop Payment",
    'shipping[name]': name,
    'shipping[address][line1]': address,
    'shipping[address][country]': "IN"
  };

  final response= await http.post(url,
  headers: {
    "Authorization": "Bearer $secretKey",
    'Content-Type': 'application/x-www-form-urlencoded'
  },
    body: body
  );

  print(body);

  if(response.statusCode==200){
    var json=jsonDecode(response.body);
    print(json);
    return json;
  }
  else{
    print("error in calling payment intent");
  }
}