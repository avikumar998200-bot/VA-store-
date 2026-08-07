import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static String ADMIN_UPI = "8955116739@ibl";

  // ONLINE - Paisa 1 baar me tumhare paas
  static Future<void> payOnline({required String orderId, required String product, required double amount, required String sellerUpi}) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'productName': product, 'amount': amount, 'sellerUpi': sellerUpi,
      'payment_method': 'online', 'status': 'paid_to_admin',
      'time': FieldValue.serverTimestamp()
    });
    String url = "upi://pay?pa=$ADMIN_UPI&pn=VA_Store&am=$amount&tn=$product&cu=INR";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // COD
  static Future<void> payCOD({required String orderId, required String product, required double amount, required String sellerUpi, String address=""}) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'productName': product, 'amount': amount, 'sellerUpi': sellerUpi,
      'payment_method': 'cod', 'status': 'cod_pending',
      'customerAddress': address,
      'time': FieldValue.serverTimestamp()
    });
  }
}
