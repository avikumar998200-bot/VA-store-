import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginChecker extends StatelessWidget {
  Future<void> checkRole(BuildContext context) async {
    var user = FirebaseAuth.instance.currentUser;
    if(user==null) return;
    var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if(!doc.exists) return;
    String role = doc['role'];
    String phone = doc['phone'] ?? '';
    if(phone == "8955116739"){
      Navigator.pushReplacementNamed(context, '/admin_home');
    } else if(role == "seller"){
      Navigator.pushReplacementNamed(context, '/seller_home');
    } else {
      Navigator.pushReplacementNamed(context, '/customer_home');
    }
  }
  @override
  Widget build(BuildContext context) {
    checkRole(context);
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
