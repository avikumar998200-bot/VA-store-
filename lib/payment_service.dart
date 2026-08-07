import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<Map<String,dynamic>> getAdmin() async {
    var doc = await FirebaseFirestore.instance.collection('admin_settings').doc('payment').get();
    if(doc.exists){return doc.data()!;}
    return {'upi_id':'8955116739@ibl','phonepe_number':'8955116739'};
  }
  static Future<void> payOnline({required String orderId, required String product, required double amount, required String sellerUpi}) async {
    var s = await getAdmin();
    String adminUpi = s['upi_id'] ?? '8955116739@ibl';
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'productName':product,'amount':amount,'sellerUpi':sellerUpi,
      'payment_method':'online','status':'paid_to_admin','adminUpi':adminUpi,
      'time':FieldValue.serverTimestamp()
    });
    String url="upi://pay?pa=$adminUpi&pn=VAStore&am=$amount&tn=$product&cu=INR";
    await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
  }
  static Future<void> payCOD({required String orderId, required String product, required double amount, required String sellerUpi, required String address}) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'productName':product,'amount':amount,'sellerUpi':sellerUpi,
      'payment_method':'cod','status':'cod_pending','customerAddress':address,
      'time':FieldValue.serverTimestamp()
    });
  }
}
