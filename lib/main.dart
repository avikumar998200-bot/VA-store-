import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (e) {}
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyHome()));
}

class MyHome extends StatefulWidget {
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Timer? timer;
  int count = 0;
  bool holding = false;
  String vid = "";

  void startHold() {
    holding = true;
    count = 0;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() { count++; });
      if (count >= 15) {
        t.cancel();
        setState(() { holding = false; count = 0; });
        showOTP();
      }
    });
  }

  void stopHold() {
    timer?.cancel();
    setState(() { holding = false; count = 0; });
  }

  void showOTP() {
    String num = "";
    String otp = "";
    bool sent = false;
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c2, set2) {
      return AlertDialog(
        title: Text("Admin Login"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(onChanged: (v) => num = v, decoration: InputDecoration(labelText: "Number")),
          if (sent) TextField(onChanged: (v) => otp = v, decoration: InputDecoration(labelText: "OTP")),
        ]),
        actions: [
          if (!sent) ElevatedButton(child: Text("Send OTP"), onPressed: () async {
            if (num.trim() != "8955116739") return;
            try {
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: "+918955116739",
                verificationCompleted: (cred) async {
                  await FirebaseAuth.instance.signInWithCredential(cred);
                  Navigator.pop(c2);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
                },
                verificationFailed: (e) {},
                codeSent: (v, r) { vid = v; set2(() => sent = true); },
                codeAutoRetrievalTimeout: (v) { vid = v; },
              );
            } catch (e) {}
          }),
          if (sent) ElevatedButton(child: Text("Verify"), onPressed: () async {
            try {
              var cr = PhoneAuthProvider.credential(verificationId: vid, smsCode: otp.trim());
              await FirebaseAuth.instance.signInWithCredential(cr);
              Navigator.pop(c2);
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
            } catch (e) {}
          }),
        ],
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPressStart: (_) => startHold(),
          onLongPressEnd: (_) => stopHold(),
          onLongPressCancel: () => stopHold(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Avira Store", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            if (holding) Text("${15-count}s hold", style: TextStyle(fontSize: 12, color: Colors.red)),
          ]),
        ),
      ),
      body: Center(child: Text("Avira Store - 15 sec hold for Admin")),
    );
  }
}

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Admin")), body: Center(child: Text("Admin Panel Open")));
  }
}
