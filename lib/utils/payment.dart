import 'dart:convert';

import 'package:carmarketplace/utils/Utils.dart';
import 'package:http/http.dart' as http;

class Payment {
  static String waafiUrl = 'https://api.waafipay.net/asm';

  static Future<Map<String, dynamic>> paymentProcessing(
      Map<String, dynamic> paymentData) async {
    try {
      String invoice = Utils.generateInvoiceId();
      var paymentBody = {
        'schemaVersion': "1.0",
        "requestId": "10111331033",
        'timestamp': DateTime.now().toString(),
        'channelName': "WEB",
        'serviceName': "API_PURCHASE",
        'serviceParams': {
          'merchantUid': "M0910291", // dotenv.env['MERCHANT_UID'],
          'apiUserId': "1000416", // dotenv.env['API_USER_ID'],
          'apiKey': "API-675418888AHX", //dotenv.env['API_KEY'],
          'paymentMethod': "mwallet_account",
          'payerInfo': {
            'accountNo': paymentData['accountNo'],
          },
          'transactionInfo': {
            'referenceId': paymentData['referenceId'],
            'invoiceId': invoice,
            'amount': paymentData['amount'],
            'currency': "USD",
            'description': paymentData['description'],
          },
        },
      };

      final response = await http.post(
        Uri.parse(waafiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentBody),
      );

      final responseData = json.decode(response.body);
      if (responseData['responseCode'] == 200) {
        return {
          'success': true,
          'message': responseData['responseMsg'] ?? 'Payment processing failed',
          'invoiceRef': invoice,
        };
      } else {
        return {
          'success': false,
          'message':
              'Server responded with status ${responseData['responseCode']}: ${responseData['responseMsg']}',
          'invoiceRef': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'An unexpected error occurred during payment processing: ${e.toString()}',
        'invoiceRef': null,
      };
    }
  }
}
