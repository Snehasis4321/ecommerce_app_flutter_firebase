import 'package:ecommerce_app/models/orders_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class MailService{

   // creating smtp server for gmail
    final gmailSmtp = gmail(dotenv.env["GMAIL_MAIL"]!, dotenv.env["GMAIL_PASSWORD"]!);
// send mail to the user using smtp
  sendMailFromGmail(String receiver, OrdersModel order) async {
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_MAIL"]!, 'No Reply')
      ..recipients.add(receiver)
      ..subject = 'Order Receipt'
      ..html = """
<body style=" font-family: Verdana, Geneva, Tahoma, sans-serif">
    <h1 style="text-align: center;">Orders Receipt</h1>

    <table style="width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; margin:   10px auto; max-width: 1000px;">
        <thead>
            <tr style="background-color: #f2f2f2; color: #333; text-align: left;">
                <th style="padding: 8px; border-bottom: 2px solid #ddd;">Image</th>
                <th style="padding: 8px; border-bottom: 2px solid #ddd;">Product</th>
                <th style="padding: 8px; border-bottom: 2px solid #ddd;">Price</th>
                <th style="padding: 8px; border-bottom: 2px solid #ddd;">Quantity</th>
                <th style="padding: 8px; border-bottom: 2px solid #ddd;">Total</th>
            </tr>
        </thead>

        <tbody>
        ${order.products.map((product) => """
<tr style="border-bottom: 1px solid #ddd; padding:  8px;">
                <td> <img src="${product.image}" alt="" style="width: 100px;"></td>
                <td style="padding: 8px;">${product.name}</td>
                <td style="padding: 8px;">₹${product.single_price}</td>
                <td style="padding: 8px;">${product.quantity}</td>
                <td style="padding: 8px;">₹${product.total_price}</td>
            </tr>
""").join("")}
    </tbody>
     
    </table>
    
    <br>

    <!-- discount and total will be in center -->
     <div class="total" style="width: 100%;   margin:   10px auto; max-width: 1000px;">
        <!-- <hr> -->

        <p style="text-align: right;  font-size: 16px; font-weight: 400;">Discount: - ₹${order.discount}</p>
        <p style="text-align: right;  font-size: 20px; font-weight: 800;">Total: ₹${order.total}</p>
     </div>
    <p style="text-align: center; font-size: 14px; color: #666;">Thank you for shopping with us!</p>
</body>
""";

    try {
      final sendReport = await send(message, gmailSmtp);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}