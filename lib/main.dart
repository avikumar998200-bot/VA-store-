import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (e) {}
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AviraStore()));
}

class AviraStore extends StatefulWidget {
  @override
  State<AviraStore> createState() => _AviraStoreState();
}

class _AviraStoreState extends State<AviraStore> {
  Timer? timer;
  int sec = 0;
  String vid = "";
  List<Map> prods = [
    {"name":"T-Shirt","price":"499"},
    {"name":"Shoes","price":"1299"},
    {"name":"Watch","price":"999"},
  ];

  void startSecret() {
    sec = 0;
    timer = Timer.periodic(Duration(seconds: 1), (t){
      sec++;
      if(sec>=15){ t.cancel(); showAdminLogin(); }
    });
  }
  void stopSecret(){ timer?.cancel(); sec=0; }

  void showAdminLogin(){
    String num=""; String otp=""; bool sent=false;
    showDialog(context: context, builder: (c)=>StatefulBuilder(builder: (c2,set2){
      return AlertDialog(
        title: Text("Admin Login"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText:"Admin Number"), onChanged: (v)=>num=v),
          if(sent) TextField(decoration: InputDecoration(labelText:"OTP"), onChanged: (v)=>otp=v),
        ]),
        actions: [
          if(!sent) ElevatedButton(child: Text("Send OTP"), onPressed: () async {
            if(num.trim()!="8955116739"){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong number"))); return; }
            try{
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: "+918955116739",
                verificationCompleted: (cred) async {
                  await FirebaseAuth.instance.signInWithCredential(cred);
                  Navigator.pop(c2);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>AdminPanel()));
                },
                verificationFailed: (e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SMS Fail: ${e.message} - google-services.json check karo"))); },
                codeSent: (v,r){ vid=v; set2(()=>sent=true); },
                codeAutoRetrievalTimeout: (v){ vid=v; },
              );
            }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"))); }
          }),
          if(sent) ElevatedButton(child: Text("Verify"), onPressed: () async {
            try{
              var cr = PhoneAuthProvider.credential(verificationId: vid, smsCode: otp.trim());
              await FirebaseAuth.instance.signInWithCredential(cr);
              Navigator.pop(c2);
              Navigator.push(context, MaterialPageRoute(builder: (_)=>AdminPanel()));
            }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong OTP"))); }
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
          onLongPressStart: (_)=>startSecret(),
          onLongPressEnd: (_)=>stopSecret(),
          onLongPressCancel: ()=>stopSecret(),
          child: Text("Avira Store", style: TextStyle(color: Color(0xFF9F2089), fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: prods.length,
        itemBuilder: (c,i)=>Card(child: ListTile(title: Text(prods[i]["name"]), subtitle: Text("Rs.${prods[i]["price"]}"))),
      ),
    );
  }
}

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Admin Panel")), body: Center(child: Text("Welcome Admin - 8955116739")) );
  }
}
