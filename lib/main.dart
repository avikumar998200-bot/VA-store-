import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AviraApp());
}

class AviraApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int idx = 0;
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: [HomeScreen(), Center(child: Text('You - Avira'))][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (v) => setState(() => idx = v),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You')
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? lpTimer;
  int lpCount = 0;
  bool isLP = false;
  String verId = '';

  void startLP() {
    isLP = true;
    lpCount = 0;
    lpTimer = Timer.periodic(Duration(seconds: 1), (t) {
      lpCount++;
      setState(() {});
      if (lpCount >= 15) {
        t.cancel();
        isLP = false;
        lpCount = 0;
        setState(() {});
        openRealSMS();
      }
    });
  }

  void cancelLP() {
    lpTimer?.cancel();
    isLP = false;
    lpCount = 0;
    setState(() {});
  }

  void openRealSMS() {
    String num = '', otp = '';
    bool sent = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) => AlertDialog(
          title: Text('Admin - Real SMS OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('8955116739 pe REAL SMS jayega', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(decoration: InputDecoration(labelText: 'Admin Number', border: OutlineInputBorder()), onChanged: (v) => num = v),
              if (sent) Padding(padding: EdgeInsets.only(top: 10), child: TextField(decoration: InputDecoration(labelText: 'SMS wala OTP', border: OutlineInputBorder()), onChanged: (v) => otp = v)),
            ],
          ),
          actions: [
            if (!sent)
              ElevatedButton(
                onPressed: () async {
                  if (num.trim()!= '8955116739') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Only 8955116739')));
                    return;
                  }
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '+918955116739',
                    verificationCompleted: (c) async {
                      await FirebaseAuth.instance.signInWithCredential(c);
                      Navigator.of(ctx, rootNavigator: true).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel()));
                    },
                    verificationFailed: (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fail: ${e.message}'), backgroundColor: Colors.red));
                    },
                    codeSent: (vId, r) {
                      verId = vId;
                      setSt(() => sent = true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('REAL SMS bhej diya'), backgroundColor: Colors.green));
                    },
                    codeAutoRetrievalTimeout: (vId) => verId = vId,
                  );
                },
                child: Text('Send REAL SMS OTP'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            if (sent)
              ElevatedButton(
                onPressed: () async {
                  try {
                    var cred = PhoneAuthProvider.credential(verificationId: verId, smsCode: otp.trim());
                    await FirebaseAuth.instance.signInWithCredential(cred);
                    Navigator.of(ctx, rootNavigator: true).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel()));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong OTP'), backgroundColor: Colors.red));
                  }
                },
                child: Text('Verify'),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onLongPressStart: (_) => startLP(),
          onLongPressEnd: (_) => cancelLP(),
          onLongPressCancel: () => cancelLP(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Avira Store', style: TextStyle(color: Color(0xFF9F2089), fontWeight: FontWeight.bold, fontSize: 22)),
              if (isLP) Text('Real SMS ${15 - lpCount}s HOLD...', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
      body: Center(child: Text('Avira Products - 15 sec dabao Admin ke liye')),
    );
  }
}

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text('ADMIN - Real SMS Verified'), backgroundColor: Colors.red, foregroundColor: Colors.white),
        body: Center(child: Text('REAL SMS se Admin khula!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      );
}
