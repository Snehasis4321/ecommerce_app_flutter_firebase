import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  static const String baseUrl = "https://cephalometric-discernably-yahir.ngrok-free.dev";

  static Future<Map<String, dynamic>> initiatePayment({
    required String phone,
    required int amount,
    required String orderId,
  }) async {
    // ✅ Ensure phone is in international format (e.g. 2547XXXXXXX)
    String formattedPhone = phone.startsWith('0')
        ? '254${phone.substring(1)}'
        : phone.startsWith('+')
        ? phone.substring(1)
        : phone;

    final url = Uri.parse("$baseUrl/stkpush");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone_number": formattedPhone,
        "amount": amount,
        "order_id": orderId, // ✅ Required by Go backend
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("M-Pesa payment failed: ${response.body}");
    }
  }
}
