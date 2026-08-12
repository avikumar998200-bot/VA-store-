import 'dart:async'; import 'dart:math'; import 'package:flutter/material.dart'; import 'package:shared_preferences/shared_preferences.dart'; import 'package:device_info_plus/device_info_plus.dart'; import 'package:firebase_core/firebase_core.dart'; import 'package:firebase_auth/firebase_auth.dart';

void main() async { WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(); runApp(AviraApp()); }
class AviraApp extends StatelessWidget { @override Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen()); }
class SessionManager { static Future<void> save(String id,String phone,String name) async { var p=await SharedPreferences.getInstance(); await p.setString('userId', id); await p.setString('phone', phone); await p.setString('name', name); await p.setBool('isLoggedIn', true); } static Future<void> logout() async { var p=await SharedPreferences.getInstance(); await p.clear(); } static Future<Map?> get() async { var p=await SharedPreferences.getInstance(); if(!(p.getBool('isLoggedIn')??false)) return null; return {'userId':p.getString('userId')}; } }
class DeviceManager { static Future<String> getId() async { try{ var d=DeviceInfoPlugin(); var a=await d.androidInfo; return a.id; }catch(e){ return 'dev_${Random().nextInt(99999)}'; } } }
class AdminPay { static String phonePe='8955116739'; static double commission=10.0; }
class UserModel { String id,name,phone,acc,pe; bool isSeller; double pending,earned; String? deviceId,forceLogout; UserModel(this.id,this.name,this.phone,{this.isSeller=false,this.acc='',this.pe='',this.pending=0,this.earned=0,this.deviceId,this.forceLogout}); }
class Product { String id,name,price,cat,sellerId,sellerName; int stock; Product(this.id,this.name,this.price,this.cat,this.sellerId,this.sellerName,{this.stock=10}); }
class Order { String id,pName,price,date,custId,custName,sellerId; bool isPaid; Order(this.id,this.pName,this.price,this.date,this.custId,this.custName,this.sellerId,{this.isPaid=false}); }
List<UserModel> USERS=[]; List<Product> PRODS=[ Product('1','Red Bridal Saree','999','Saree','admin','Avira Store',stock:20), Product('2','Designer Kurti','599','Kurti','admin','Avira Store',stock:15), ]; List<Order> ORDERS=[]; String? L_ID; String? L_NAME;

class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }
class _MainScreenState extends State<MainScreen> { int idx=0; @override Widget build(BuildContext c){ return Scaffold(body: [HomeScreen(), SearchScreen(), YouScreen()][idx], bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (v)=>setState(()=>idx=v), selectedItemColor: Color(0xFF9F2089), items: [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You')])); } }

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  String cat='All'; Timer? lpTimer; int lpCount=0; bool isLP=false; String verId='';

  void startLP(){ isLP=true; lpCount=0; lpTimer=Timer.periodic(Duration(seconds:1), (t){ lpCount++; setState((){}); if(lpCount>=15){ t.cancel(); isLP=false; lpCount=0; setState((){}); openAdmin(); } }); }
  void cancelLP(){ lpTimer?.cancel(); isLP=false; lpCount=0; setState((){}); }

  void openAdmin(){
    String num='',otp=''; bool otpSent=false;
    showDialog(context: context, builder: (ctx)=> StatefulBuilder(builder: (ctx2,setSt)=> AlertDialog(
      title: Text('Admin Secure - Real SMS'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Text('Admin No: 8955116739', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        TextField(decoration: InputDecoration(labelText: 'Admin Number', border: OutlineInputBorder()), onChanged:(v)=>num=v),
        if(otpSent)...[
          SizedBox(height:10),
          Text('OTP SMS me gaya hai - Inbox dekho', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize:11)),
          TextField(decoration: InputDecoration(labelText: 'OTP from SMS', border: OutlineInputBorder()), onChanged:(v)=>otp=v),
        ]
      ]),
      actions:[
        if(!otpSent) ElevatedButton(onPressed:() async {
          if(num.trim()!='8955116739'){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong Number'))); return; }
          // REAL SMS FIREBASE SE
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: '+918955116739',
            verificationCompleted: (c) async { await FirebaseAuth.instance.signInWithCredential(c); Navigator.of(ctx, rootNavigator: true).pop(); Navigator.push(context, MaterialPageRoute(builder:(_)=> AdminPanel())); },
            verificationFailed: (e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fail ${e.message}'), backgroundColor: Colors.red)); },
            codeSent: (String vId, int? t){ verId=vId; setSt(()=>otpSent=true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP SMS se bhej diya 8955116739 pe - Inbox check karo'), backgroundColor: Colors.green)); },
            codeAutoRetrievalTimeout: (vId){ verId=vId; },
          );
        }, child: Text('Send OTP via Real SMS'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white)),
        if(otpSent) ElevatedButton(onPressed:() async {
          try{
            var cred = PhoneAuthProvider.credential(verificationId: verId, smsCode: otp.trim());
            await FirebaseAuth.instance.signInWithCredential(cred);
            Navigator.of(ctx, rootNavigator: true).pop();
            L_ID='ADMIN'; L_NAME='Admin';
            Navigator.push(context, MaterialPageRoute(builder:(_)=> AdminPanel()));
          } catch(e){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong OTP - SMS wala dalo'), backgroundColor: Colors.red));
          }
        }, child: Text('Verify Real OTP'))
      ],
    )));
  }

  @override Widget build(BuildContext c){
    var list=PRODS.where((p)=> cat=='All' || p.cat==cat).toList();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: GestureDetector(onLongPressStart: (_)=>startLP(), onLongPressEnd: (_)=>cancelLP(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text('Avira Store', style: TextStyle(color: Color(0xFF9F2089),fontWeight: FontWeight.bold,fontSize:22)), if(isLP) Text('Admin ${15-lpCount}s HOLD...', style: TextStyle(fontSize:12,color:Colors.red, fontWeight: FontWeight.bold)) ]))),
      body: Column(children:[
        Container(width: double.infinity, color: Color(0xFFE8F5E9), padding: EdgeInsets.all(8), child: Text('100% Secure - Real SMS OTP Admin', style: TextStyle(fontSize:11,color:Colors.green))),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.7,crossAxisSpacing:10,mainAxisSpacing:10), itemCount:list.length, itemBuilder:(ctx,i){ return Card(child: Column(children:[ Expanded(child: Icon(Icons.image,size:40)), Text(list[i].name), ElevatedButton(onPressed: (){}, child: Text('Buy Now')) ])); }))
      ]),
    );
  }
}
class SearchScreen extends StatelessWidget { @override Widget build(BuildContext c)=> Scaffold(appBar: AppBar(title: Text('Search')), body: Center(child: Text('Search'))); }
class YouScreen extends StatelessWidget { @override Widget build(BuildContext c)=> Scaffold(appBar: AppBar(title: Text('You')), body: Center(child: Text('Login'))); }
class AdminPanel extends StatelessWidget { @override Widget build(BuildContext c)=> Scaffold(appBar: AppBar(title: Text('ADMIN - Real SMS Verified'), backgroundColor: Colors.red, foregroundColor: Colors.white), body: Center(child: Text('Admin Panel - OTP SMS se khula', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)))); }
