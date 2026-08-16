import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch(e){}
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AviraMain()));
}

List<String> categories = ["Men", "Women", "Kids", "Electronics"];
List<Map> allProducts = [
  {"name":"T-Shirt","price":"499","cat":"Men","photo":"","approved":true},
  {"name":"Shoes","price":"1299","cat":"Men","photo":"","approved":true},
  {"name":"Watch","price":"999","cat":"Electronics","photo":"","approved":true},
];

class AviraMain extends StatefulWidget { @override State<AviraMain> createState() => _AviraMainState(); }

class _AviraMainState extends State<AviraMain> {
  int idx=0;
  Timer? t; int sec=0;
  void startSec(){ sec=0; t=Timer.periodic(Duration(seconds:1),(x){sec++; if(sec>=15){x.cancel(); _showOtp(isAdmin:true);}}); }
  void stopSec(){ t?.cancel(); sec=0; }

  void _showOtp({required bool isAdmin, String? preset}){
    String num=preset??""; String otp=""; String vid=""; bool sent=false;
    showDialog(context: context, builder: (c)=>StatefulBuilder(builder:(c2,s2){
      return AlertDialog(
        title: Text(isAdmin?"Admin Login":"OTP Verification"),
        content: Column(mainAxisSize: MainAxisSize.min, children:[
          TextField(decoration: InputDecoration(labelText:"Mobile Number"), keyboardType: TextInputType.phone, onChanged:(v)=>num=v),
          if(isAdmin) Text("Only 8955116739", style:TextStyle(fontSize:10,color:Colors.red)),
          if(sent) TextField(decoration: InputDecoration(labelText:"Enter OTP"), onChanged:(v)=>otp=v),
        ]),
        actions:[
          if(!sent) ElevatedButton(child: Text("Send OTP - Real SMS"), onPressed: () async {
            String fn = num.trim();
            if(isAdmin && fn!="8955116739"){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Sirf Admin number"))); return; }
            if(fn.length<10) return;
            String phone = fn.startsWith("+")?fn:"+91$fn";
            try{
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: phone,
                verificationCompleted: (cred) async { await FirebaseAuth.instance.signInWithCredential(cred); Navigator.pop(c2); if(isAdmin) Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminPanel())); else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Verified $phone"))); },
                verificationFailed: (e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("SMS Fail: google-services.json lagao"))); },
                codeSent: (v,r){ vid=v; s2(()=>sent=true); },
                codeAutoRetrievalTimeout: (v){ vid=v; },
              );
            }catch(e){}
          }),
          if(sent) ElevatedButton(child: Text("Verify OTP"), onPressed: () async {
            try{ var cr=PhoneAuthProvider.credential(verificationId: vid, smsCode: otp.trim()); await FirebaseAuth.instance.signInWithCredential(cr); Navigator.pop(c2); if(isAdmin) Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminPanel())); }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Galat OTP"))); }
          }),
        ],
      );
    }));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: GestureDetector(onLongPressStart: (_)=>startSec(), onLongPressEnd: (_)=>stopSec(), onLongPressCancel: ()=>stopSec(), child: Text("Avira Store", style:TextStyle(color:Color(0xFF9F2089),fontWeight: FontWeight.bold)))),
      body: [HomeTab(), SearchTab(), CartTab(), YouTab(onLogin: ()=>_showOtp(isAdmin:false))][idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap:(v)=>setState(()=>idx=v), selectedItemColor: Color(0xFF9F2089), type: BottomNavigationBarType.fixed, items:[
        BottomNavigationBarItem(icon: Icon(Icons.home), label:"Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label:"Search"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label:"Cart"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label:"You"),
      ]),
    );
  }
}

class HomeTab extends StatefulWidget{ @override State<HomeTab> createState()=>_HomeTabState(); }
class _HomeTabState extends State<HomeTab>{
  String selCat="All";
  @override Widget build(BuildContext c){
    List<Map> filtered = selCat=="All"?allProducts.where((p)=>p["approved"]==true).toList():allProducts.where((p)=>p["cat"]==selCat && p["approved"]==true).toList();
    return Column(children:[
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children:[ ChoiceChip(label: Text("All"), selected: selCat=="All", onSelected: (_)=>setState(()=>selCat="All")),...categories.map((cat)=>Padding(padding: EdgeInsets.only(left:6), child: ChoiceChip(label: Text(cat), selected: selCat==cat, onSelected: (_)=>setState(()=>selCat=cat)))).toList() ])),
      Expanded(child: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8), itemCount: filtered.length, itemBuilder: (c,i)=>Card(child: Column(children:[ Container(height:90, color: Colors.grey[200], child: Icon(Icons.image,size:40)), Text(filtered[i]["name"]), Text("Rs.${filtered[i]["price"]}"), Text(filtered[i]["cat"], style:TextStyle(fontSize:10)) ]))))
    ]);
  }
}
class SearchTab extends StatelessWidget{ @override Widget build(BuildContext c){ return Center(child: Text("Search")); } }
class CartTab extends StatelessWidget{ @override Widget build(BuildContext c){ return Center(child: Text("Cart")); } }

class YouTab extends StatefulWidget{ final Function() onLogin; YouTab({required this.onLogin}); @override State<YouTab> createState()=>_YouTabState(); }
class _YouTabState extends State<YouTab>{
  String name=""; String price=""; String selCat="Men"; XFile? picked;
  TextEditingController newCatCtrl = TextEditingController();
  Future<void> pickImg() async { try{ var img = await ImagePicker().pickImage(source: ImageSource.gallery); setState(()=>picked=img); }catch(e){} }
  @override Widget build(BuildContext c){
    return Padding(padding: EdgeInsets.all(15), child: ListView(children:[
      ElevatedButton(onPressed: ()=>widget.onLogin(), child: Text("Customer Login - Real SMS OTP jayega")),
      SizedBox(height:10),
      ElevatedButton(onPressed: ()=>widget.onLogin(), child: Text("Seller Login - Real SMS OTP jayega")),
      Divider(), Text("Seller - Add Product with Photo & Category", style:TextStyle(fontWeight: FontWeight.bold)),
      TextField(decoration: InputDecoration(labelText:"Product Name"), onChanged:(v)=>name=v),
      TextField(decoration: InputDecoration(labelText:"Price"), onChanged:(v)=>price=v),
      DropdownButton<String>(value: selCat, isExpanded:true, items: categories.map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged:(v)=>setState(()=>selCat=v!)),
      Row(children:[ Expanded(child: TextField(controller: newCatCtrl, decoration: InputDecoration(labelText:"Nayi Category"))), ElevatedButton(onPressed: (){ if(newCatCtrl.text.trim().isEmpty) return; setState((){ categories.add(newCatCtrl.text.trim()); selCat=newCatCtrl.text.trim(); newCatCtrl.clear(); }); }, child: Text("Add Cat")) ]),
      ElevatedButton.icon(onPressed: pickImg, icon: Icon(Icons.photo), label: Text(picked==null?"Product Photo Add":"Photo Selected")),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9F2089)), onPressed: (){ if(name.isEmpty||price.isEmpty) return; setState(()=>allProducts.add({"name":name,"price":price,"cat":selCat,"photo":picked?.path??"","approved":false})); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added - Admin Approval Pending"))); }, child: Text("Add Product", style:TextStyle(color:Colors.white))),
    ]));
  }
}

class AdminPanel extends StatefulWidget{ @override State<AdminPanel> createState()=>_AdminPanelState(); }
class _AdminPanelState extends State<AdminPanel>{
  @override Widget build(BuildContext c){
    List<Map> pending = allProducts.where((p)=>p["approved"]==false).toList();
    return Scaffold(appBar: AppBar(title: Text("Admin Panel - Real SMS Login")), body: ListView(children:[...pending.map((p)=>Card(child: ListTile(title: Text("${p["name"]} - Rs.${p["price"]}"), subtitle: Text("Cat:${p["cat"]} Photo:${p["photo"]!=""?"Yes":"No"}"), trailing: ElevatedButton(child: Text("Approve"), onPressed: ()=>setState(()=>p["approved"]=true))))).toList() ]));
  }
}
