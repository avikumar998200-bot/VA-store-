import 'dart:async'; import 'dart:math'; import 'package:flutter/material.dart'; import 'package:shared_preferences/shared_preferences.dart'; import 'package:device_info_plus/device_info_plus.dart'; import 'package:firebase_core/firebase_core.dart'; import 'package:firebase_auth/firebase_auth.dart';
void main() async { WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(); runApp(AviraApp()); }
class AviraApp extends StatelessWidget { @override Widget build(BuildContext c) => MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen()); }
class SessionManager { static Future<void> save(String id) async { var p=await SharedPreferences.getInstance(); await p.setString('userId', id); await p.setBool('isLoggedIn', true); } }
class Product { String id,name,price; Product(this.id,this.name,this.price); }
List<Product> PRODS=[ Product('1','Red Saree','999'), Product('2','Kurti','599'), ];
class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }
class _MainScreenState extends State<MainScreen> { int idx=0; @override Widget build(BuildContext c){ return Scaffold(body: [HomeScreen(), Center(child: Text('You'))][idx], bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap:(v)=>setState(()=>idx=v), items:[BottomNavigationBarItem(icon:Icon(Icons.home), label:'Home'), BottomNavigationBarItem(icon:Icon(Icons.person), label:'You')])); } }
class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  Timer? lpTimer; int lpCount=0; bool isLP=false; String verId='';
  void startLP(){ isLP=true; lpCount=0; lpTimer=Timer.periodic(Duration(seconds:1), (t){ lpCount++; setState((){}); if(lpCount>=15){ t.cancel(); isLP=false; lpCount=0; setState((){}); openRealSMS(); } }); }
  void cancelLP(){ lpTimer?.cancel(); isLP=false; lpCount=0; setState((){}); }

  void openRealSMS(){
    String num='',otp=''; bool sent=false;
    showDialog(context: context, builder: (ctx)=> StatefulBuilder(builder: (ctx2,setSt)=> AlertDialog(
      title: Text('Admin - Real SMS OTP'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Text('Number: 8955116739 pe real SMS jayega', style: TextStyle(fontSize:11, color:Colors.green, fontWeight:FontWeight.bold)),
        SizedBox(height:8),
        TextField(decoration: InputDecoration(labelText:'Admin Number', border: OutlineInputBorder()), onChanged:(v)=>num=v),
        if(sent) Padding(padding: EdgeInsets.only(top:10), child: TextField(decoration: InputDecoration(labelText:'SMS wala OTP dalo', border: OutlineInputBorder()), onChanged:(v)=>otp=v)),
        if(sent) Text('Inbox me dekho - Firebase se SMS aya hoga', style: TextStyle(fontSize:9, color:Colors.green))
      ]),
      actions:[
        if(!sent) ElevatedButton(onPressed:() async {
          if(num.trim()!='8955116739'){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Sirf 8955116739 allowed'))); return; }
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: '+918955116739',
            verificationCompleted: (PhoneAuthCredential c) async { await FirebaseAuth.instance.signInWithCredential(c); Navigator.of(ctx, rootNavigator:true).pop(); Navigator.push(context, MaterialPageRoute(builder:(_)=> AdminPanel())); },
            verificationFailed: (FirebaseAuthException e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Fail: ${e.message}'), backgroundColor:Colors.red)); },
            codeSent: (String vId, int? r){ verId=vId; setSt(()=>sent=true); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('REAL SMS bhej diya 8955116739 pe - Inbox dekho'), backgroundColor:Colors.green, duration:Duration(seconds:5))); },
            codeAutoRetrievalTimeout: (String vId){ verId=vId; },
          );
        }, child:Text('Send REAL SMS OTP'), style:ElevatedButton.styleFrom(backgroundColor:Colors.red,foregroundColor:Colors.white)),
        if(sent) ElevatedButton(onPressed:() async {
          try{
            var cred=PhoneAuthProvider.credential(verificationId: verId, smsCode: otp.trim());
            await FirebaseAuth.instance.signInWithCredential(cred);
            Navigator.of(ctx, rootNavigator:true).pop();
            Navigator.push(context, MaterialPageRoute(builder:(_)=> AdminPanel()));
          } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Galat OTP - SMS wala dalo'), backgroundColor:Colors.red)); }
        }, child:Text('Verify Real OTP'))
      ],
    )));
  }

  @override Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: GestureDetector(onLongPressStart: (_)=>startLP(), onLongPressEnd: (_)=>cancelLP(), onLongPressCancel: ()=>cancelLP(), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ Text('Avira Store', style:TextStyle(color:Color(0xFF9F2089),fontWeight:FontWeight.bold,fontSize:22)), if(isLP) Text('Real SMS Admin ${15-lpCount}s HOLD...', style:TextStyle(fontSize:12,color:Colors.red, fontWeight:FontWeight.bold)) ]))),
      body: Column(children:[
        Container(width:double.infinity, color:Color(0xFFE8F5E9), padding:EdgeInsets.all(8), child:Text('15 sec dabao - REAL SMS OTP ayega 8955116739 pe', style:TextStyle(fontSize:11,color:Colors.green,fontWeight:FontWeight.bold))),
        Expanded(child: GridView.builder(padding:EdgeInsets.all(10), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.7), itemCount:PRODS.length, itemBuilder:(ctx,i){ return Card(child:Column(children:[Expanded(child:Icon(Icons.image,size:50)), Text(PRODS[i].name), Text('Rs.${PRODS[i].price}')])); }))
      ]),
    );
  }
}
class AdminPanel extends StatelessWidget { @override Widget build(BuildContext c)=> Scaffold(appBar:AppBar(title:Text('ADMIN - Real SMS Verified'), backgroundColor:Colors.red, foregroundColor:Colors.white), body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center, children:[ Icon(Icons.sms, size:80, color:Colors.green), SizedBox(height:10), Text('REAL SMS se Admin khula!', style:TextStyle(fontSize:20, fontWeight:FontWeight.bold)), Text('8955116739 pe Firebase ka SMS aya'), SizedBox(height:20), ElevatedButton(onPressed:() async { await FirebaseAuth.instance.signOut(); Navigator.pop(c); }, child:Text('Logout')) ]))); }
