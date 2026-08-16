import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch(e){}
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AviraMain()));
}

class AviraMain extends StatefulWidget {
  @override
  State<AviraMain> createState() => _AviraMainState();
}

class _AviraMainState extends State<AviraMain> {
  int idx=0;
  Timer? t; int sec=0;
  void startSec(){ sec=0; t=Timer.periodic(Duration(seconds:1),(x){sec++; if(sec>=15){x.cancel(); showAdmin();}}); }
  void stopSec(){ t?.cancel(); sec=0; }

  void showAdmin(){ _showOtpDialog(isAdmin:true); }
  void _showOtpDialog({required bool isAdmin, String? presetNum}){
    String num=presetNum??""; String otp=""; String vid=""; bool sent=false;
    showDialog(context: context, builder: (c)=>StatefulBuilder(builder:(c2,s2){
      return AlertDialog(
        title: Text(isAdmin?"Admin Login":"OTP Verification"),
        content: Column(mainAxisSize: MainAxisSize.min, children:[
          if(!isAdmin || presetNum==null)
          TextField(decoration: InputDecoration(labelText:"Mobile Number"), keyboardType:TextInputType.phone, onChanged:(v)=>num=v),
          if(isAdmin) Text("Only 8955116739 allowed", style:TextStyle(fontSize:10,color:Colors.red)),
          if(sent) SizedBox(height:10),
          if(sent) TextField(decoration: InputDecoration(labelText:"Enter OTP"), onChanged:(v)=>otp=v),
        ]),
        actions:[
          if(!sent) ElevatedButton(child: Text("Send OTP"), onPressed: () async {
            String finalNum = num.trim();
            if(isAdmin && finalNum!="8955116739"){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Sirf Admin number allowed"))); return; }
            if(finalNum.length<10){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Number sahi dalo"))); return; }
            String phone = finalNum.startsWith("+")?finalNum:"+91$finalNum";
            try{
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: phone,
                verificationCompleted: (cred) async { await FirebaseAuth.instance.signInWithCredential(cred); Navigator.pop(c2); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Login Success $phone"))); if(isAdmin) Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminPanel())); },
                verificationFailed: (e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("SMS Fail: ${e.message} - google-services.json check karo"))); },
                codeSent: (v,r){ vid=v; s2(()=>sent=true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("OTP bheja $phone pe"))); },
                codeAutoRetrievalTimeout: (v){ vid=v; },
              );
            }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Error $e"))); }
          }),
          if(sent) ElevatedButton(child: Text("Verify OTP"), onPressed: () async {
            try{
              var cr = PhoneAuthProvider.credential(verificationId: vid, smsCode: otp.trim());
              await FirebaseAuth.instance.signInWithCredential(cr);
              Navigator.pop(c2);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Verified $num")));
              if(isAdmin) Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminPanel()));
            }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Galat OTP"))); }
          }),
        ],
      );
    }));
  }

  @override
  Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: GestureDetector(onLongPressStart: (_)=>startSec(), onLongPressEnd: (_)=>stopSec(), onLongPressCancel: ()=>stopSec(), child: Text("Avira Store", style:TextStyle(color:Color(0xFF9F2089),fontWeight:FontWeight.bold)))),
      body: [HomeScreen(), SearchScreen(), CartScreen(), YouScreen(onLogin:(isSeller){ _showOtpDialog(isAdmin:false); })][idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, selectedItemColor: Color(0xFF9F2089), onTap:(v)=>setState(()=>idx=v), type: BottomNavigationBarType.fixed, items:[
        BottomNavigationBarItem(icon: Icon(Icons.home), label:"Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label:"Search"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label:"Cart"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label:"You"),
      ]),
    );
  }
}

class HomeScreen extends StatelessWidget{ @override Widget build(BuildContext c){ return ListView(children:[ Card(child: ListTile(title:Text("T-Shirt"), subtitle:Text("Rs.499"))), Card(child: ListTile(title:Text("Shoes"), subtitle:Text("Rs.1299"))), Card(child: ListTile(title:Text("Watch"), subtitle:Text("Rs.999"))), ]); } }
class SearchScreen extends StatelessWidget{ @override Widget build(BuildContext c){ return Center(child: Text("Search Products")); } }
class CartScreen extends StatelessWidget{ @override Widget build(BuildContext c){ return Center(child: Text("Cart Empty")); } }
class YouScreen extends StatelessWidget{
  final Function(bool) onLogin; YouScreen({required this.onLogin});
  @override Widget build(BuildContext c){
    return Padding(padding: EdgeInsets.all(20), child: Column(children:[
      ElevatedButton(onPressed: ()=>onLogin(false), child: Text("Customer Login - OTP jayega")), SizedBox(height:10),
      ElevatedButton(onPressed: ()=>onLogin(true), child: Text("Seller Bano - OTP jayega")), SizedBox(height:20),
      Text("Admin ke liye upar Avira Store ko 15 sec dabao", style:TextStyle(fontSize:10,color:Colors.grey)),
    ]));
  }
}
class AdminPanel extends StatelessWidget{ @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title:Text("Admin Panel")), body: Center(child: Text("Admin 8955116739 - Sab orders yaha"))); } }
