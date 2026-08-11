import 'dart:math';
import 'package:flutter/material.dart';

void main() { runApp(AviraApp()); }

class AviraApp extends StatelessWidget {
  @override Widget build(BuildContext c) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}

// ADMIN OTP - 8955116739 - TUM DALOGE - BAHAR NAHI DIKHEGA
class AdminSecure {
  static const String _adminNum = "8955116739";
  static String _otp = "";
  static String genOTP() {
    _otp = (100000 + Random().nextInt(900000)).toString();
    return _otp;
  }
  static bool verify(String n, String o) => n.trim() == _adminNum && o == _otp;
  static bool isAdmin(String n) => n.trim() == _adminNum;
}

class UserModel {
  String id,name,phone,addr,aadhar,acc,pe,shop;
  bool isSeller,isApproved;
  UserModel(this.id,this.name,this.phone,this.addr,{this.isSeller=false,this.isApproved=false,this.aadhar="",this.acc="",this.pe="",this.shop=""});
}
class Product {
  String id,name,price,cat,sellerId,sellerName,sellerPhone;
  int stock; bool inStock,isApproved;
  Product(this.id,this.name,this.price,this.cat,this.sellerId,this.sellerName,this.sellerPhone,{this.stock=10,this.inStock=true,this.isApproved=false});
}
class Order {
  String id,pName,price,date,custId,custName,custPhone,sellerId,status;
  Order(this.id,this.pName,this.price,this.date,this.custId,this.custName,this.custPhone,this.sellerId,{this.status="Placed"});
}
class CartItem { String pId; int qty; CartItem(this.pId,this.qty); }
class Notif { String id,title,msg,date,pId,sId; bool isRead; Notif(this.id,this.title,this.msg,this.date,this.pId,this.sId,{this.isRead=false}); }

List<UserModel> USERS = [];
List<Product> PRODS = [];
List<Order> ORDERS = [];
List<Notif> ADMIN_NOTIFS = [];
List<Notif> SELLER_NOTIFS = [];
List<CartItem> CART = [];
String? L_ID; String? L_NAME;

class MainScreen extends StatefulWidget { @override _MainScreenState createState()=>_MainScreenState(); }
class _MainScreenState extends State<MainScreen> {
  int idx=0;
  @override Widget build(BuildContext c) {
    return Scaffold(
      body: [HomeScreen(), SearchScreen(), CartScreen(), YouScreen()][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, selectedItemColor: Color(0xFF9F2089),
        onTap: (v)=>setState(()=>idx=v),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "You"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  String cat="All";
  void buy(Product p) {
    if(L_ID==null){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pehle Login - You tab"))); return; }
    if(!p.inStock || p.stock<=0){
      ADMIN_NOTIFS.insert(0, Notif(DateTime.now().millisecondsSinceEpoch.toString(), "OUT: ${p.name}", "Out! Seller:${p.sellerName} ${p.sellerPhone}", "${DateTime.now().day}-${DateTime.now().month}", p.id, p.sellerId));
      SELLER_NOTIFS.insert(0, Notif(DateTime.now().millisecondsSinceEpoch.toString(), "Out: ${p.name}", "Stock khatam!", "${DateTime.now().day}-${DateTime.now().month}", p.id, p.sellerId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Out of Stock! Admin & Seller ko notify"), backgroundColor: Colors.red)); return;
    }
    setState(()=>p.stock--);
    if(p.stock<=0){ p.inStock=false; ADMIN_NOTIFS.insert(0, Notif(DateTime.now().millisecondsSinceEpoch.toString(), "OUT: ${p.name}", "Out! ${p.sellerPhone}", "${DateTime.now().day}-${DateTime.now().month}", p.id, p.sellerId)); }
    var u=USERS.firstWhere((e)=>e.id==L_ID, orElse:()=>UserModel("g","Guest","",""));
    ORDERS.add(Order(DateTime.now().millisecondsSinceEpoch.toString(), p.name, p.price, "${DateTime.now().day}-${DateTime.now().month}", L_ID!, L_NAME!, u.phone, p.sellerId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ordered! Stock:${p.stock}"), backgroundColor: Colors.green));
  }
  @override Widget build(BuildContext c){
    var list=PRODS.where((p)=>p.isApproved && (cat=="All"||p.cat==cat)).toList();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Avira",style:TextStyle(color:Color(0xFF9F2089),fontWeight:FontWeight.bold))),
      body: Column(children:[
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ["All","Saree","Kurti","Lehenga","Suits"].map((e)=>Padding(padding: EdgeInsets.all(4), child: ChoiceChip(label: Text(e), selected: cat==e, onSelected:(v)=>setState(()=>cat=e)))).toList())),
        Expanded(child: list.isEmpty?Center(child: Text("No Products - Seller add karega, Admin approve karega")):GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.65,crossAxisSpacing:8,mainAxisSpacing:8), itemCount: list.length, itemBuilder: (ctx,i){
          var p=list[i];
          return Card(child: Column(children:[
            Expanded(child: Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image)))),
            Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Text(p.name,style: TextStyle(fontWeight:FontWeight.bold,fontSize:11)),
              Text("By:${p.sellerName}",style: TextStyle(fontSize:9,color:Color(0xFF9F2089))),
              Text("₹${p.price} | Stock:${p.stock}",style: TextStyle(fontSize:11,color: p.inStock?Colors.green:Colors.red)),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=>buy(p), child: Text(p.inStock?"Buy":"Out",style:TextStyle(fontSize:9)), style: ElevatedButton.styleFrom(backgroundColor: p.inStock?Color(0xFF9F2089):Colors.grey, foregroundColor: Colors.white)))
            ]))
          ]));
        }))
      ])
    );
  }
}

class SearchScreen extends StatefulWidget { @override _SearchScreenState createState()=>_SearchScreenState(); }
class _SearchScreenState extends State<SearchScreen> {
  String q="";
  @override Widget build(BuildContext c){
    var list=PRODS.where((p)=>p.isApproved && p.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(appBar: AppBar(title: Text("Search - Server se"), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white),
      body: Column(children:[
        Padding(padding: EdgeInsets.all(10), child: TextField(decoration: InputDecoration(hintText: "Search - Server se ayega", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged:(v)=>setState(()=>q=v))),
        Expanded(child: ListView.builder(itemCount: list.length, itemBuilder:(ctx,i){ var p=list[i]; return Card(child: ListTile(leading: CircleAvatar(child: Text("${p.stock}")), title: Text("${p.name} - ₹${p.price}"), subtitle: Text("By:${p.sellerName} | Stock:${p.stock} | ${p.inStock?"In Stock":"Out"}"))); }))
      ])
    );
  }
}

class CartScreen extends StatefulWidget { @override _CartScreenState createState()=>_CartScreenState(); }
class _CartScreenState extends State<CartScreen> {
  @override Widget build(BuildContext c){
    var items=CART.map((e){ var p=PRODS.where((x)=>x.id==e.pId).toList(); return p.isNotEmpty?{"prod":p[0],"qty":e.qty,"cart":e}:null; }).where((e)=>e!=null).toList();
    int total=items.fold(0,(s,e){ var p=e!["prod"] as Product; var q=e["qty"] as int; return s+(int.tryParse(p.price)??0)*q; });
    return Scaffold(appBar: AppBar(title: Text("Cart ${CART.length}"), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white),
      body: Column(children:[
        Expanded(child: items.isEmpty?Center(child: Text("Cart Empty")):ListView.builder(itemCount: items.length, itemBuilder:(ctx,i){ var e=items[i]!; var p=e["prod"] as Product; var q=e["qty"] as int; var ci=e["cart"] as CartItem; return Card(child: ListTile(leading: CircleAvatar(child: Text("$q")), title: Text(p.name), subtitle: Text("₹${p.price} x $q"), trailing: IconButton(icon: Icon(Icons.delete,color:Colors.red), onPressed:(){ setState(()=>CART.remove(ci)); }))); })),
        Container(padding: EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed:(){ if(L_ID==null) return; for(var e in items){ var p=e!["prod"] as Product; var q=e["qty"] as int; if(p.stock>=q){ setState(()=>p.stock-=q); if(p.stock<=0) p.inStock=false; var u=USERS.firstWhere((x)=>x.id==L_ID); ORDERS.add(Order(DateTime.now().millisecondsSinceEpoch.toString(),p.name,p.price,"${DateTime.now().day}-${DateTime.now().month}",L_ID!,L_NAME!,u.phone,p.sellerId)); } } setState(()=>CART.clear()); }, child: Text("Place All - ₹$total"), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white))))
      ])
    );
  }
}

class YouScreen extends StatefulWidget { @override _YouScreenState createState()=>_YouScreenState(); }
class _YouScreenState extends State<YouScreen> {
  void adminOTP(){
    String num="",otp="",gen="";
    showDialog(context: context, builder:(ctx)=>StatefulBuilder(builder:(ctx2,setSt)=>AlertDialog(
      title: Text("Admin OTP Login - 8955116739"),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Text("Number tum daloge",style: TextStyle(fontSize:11)),
        TextField(decoration: InputDecoration(labelText: "Admin Number", hintText: "8955116739", border: OutlineInputBorder()), keyboardType: TextInputType.phone, onChanged:(v)=>num=v),
        SizedBox(height:10),
        if(gen.isNotEmpty)...[
          Container(color: Colors.green[50], padding: EdgeInsets.all(8), child: Text("OTP:$gen",style: TextStyle(fontWeight:FontWeight.bold))),
          TextField(decoration: InputDecoration(labelText: "OTP", border: OutlineInputBorder()), onChanged:(v)=>otp=v),
        ]
      ]),
      actions:[
        if(gen.isEmpty) TextButton(onPressed:(){
          if(!AdminSecure.isAdmin(num)){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ye Admin Number nahi!"), backgroundColor: Colors.red)); return; }
          String o=AdminSecure.genOTP(); setSt(()=>gen=o);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP:$o"), backgroundColor: Colors.green));
        }, child: Text("Send OTP")),
        if(gen.isNotEmpty) TextButton(onPressed:(){
          if(AdminSecure.verify(num,otp)){ Navigator.pop(ctx); L_ID="ADMIN"; L_NAME="Admin"; Navigator.push(context, MaterialPageRoute(builder:(_)=>AdminPanel(adminNum:num))); setState((){}); }
          else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong OTP"), backgroundColor: Colors.red));
        }, child: Text("Verify"))
      ]
    )));
  }
  void userLogin(bool seller){
    String name="",phone="",addr="",aad="",acc="",pe="",shop="";
    showDialog(context: context, builder:(ctx)=>AlertDialog(
      title: Text(seller?"Seller Registration":"Customer Registration"),
      content: SingleChildScrollView(child: Column(children:[
        TextField(decoration: InputDecoration(labelText: "Name*", border: OutlineInputBorder()), onChanged:(v)=>name=v),
        TextField(decoration: InputDecoration(labelText: "Phone* - Sirf Admin dekhega", border: OutlineInputBorder()), onChanged:(v)=>phone=v),
        TextField(decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder()), onChanged:(v)=>addr=v),
        if(seller)...[
          TextField(decoration: InputDecoration(labelText: "Shop", border: OutlineInputBorder()), onChanged:(v)=>shop=v),
          TextField(decoration: InputDecoration(labelText: "Aadhar - Sirf Admin", border: OutlineInputBorder()), onChanged:(v)=>aad=v),
          TextField(decoration: InputDecoration(labelText: "Account", border: OutlineInputBorder()), onChanged:(v)=>acc=v),
          TextField(decoration: InputDecoration(labelText: "PhonePe", border: OutlineInputBorder()), onChanged:(v)=>pe=v),
        ],
      ])),
      actions:[ TextButton(onPressed:(){
        if(name.isEmpty||phone.isEmpty) return;
        String id="U_${DateTime.now().millisecondsSinceEpoch}";
        USERS.add(UserModel(id,name,phone,addr,isSeller:seller,isApproved:false,aadhar:aad,acc:acc,pe:pe,shop:shop));
        L_ID=id; L_NAME=name; Navigator.pop(ctx);
        if(seller) Navigator.push(context, MaterialPageRoute(builder:(_)=>SellerPanel(sId:id,sName:name)));
        setState((){});
      }, child: Text("Register")) ]
    ));
  }
  @override Widget build(BuildContext c){
    return Scaffold(appBar: AppBar(title: Text("You - Avira")),
      body: Column(children:[
        Card(color: Colors.red[50], child: ListTile(leading: Icon(Icons.admin_panel_settings,color:Colors.red), title: Text("Admin Login - OTP"), subtitle: Text("Number tum daloge 8955116739 - Andar sab dikhega"), onTap: adminOTP)),
        ListTile(leading: Icon(Icons.person,color:Colors.blue), title: Text("Customer Login"), subtitle: Text("Number sirf Admin dekhega"), onTap:()=>userLogin(false)),
        ListTile(leading: Icon(Icons.store,color:Colors.green), title: Text("Seller Login - Delete/Edit"), subtitle: Text("Apne products delete/edit"), onTap:()=>userLogin(true)),
      ])
    );
  }
}

class SellerPanel extends StatefulWidget { String sId,sName; SellerPanel({required this.sId,required this.sName}); @override _SellerPanelState createState()=>_SellerPanelState(); }
class _SellerPanelState extends State<SellerPanel> {
  String tab="Prod";
  @override Widget build(BuildContext c){
    var myP=PRODS.where((p)=>p.sellerId==widget.sId).toList();
    var myO=ORDERS.where((o)=>o.sellerId==widget.sId).toList();
    var myN=SELLER_NOTIFS.where((n)=>n.sId==widget.sId).toList();
    return Scaffold(appBar: AppBar(title: Text("Seller:${widget.sName}"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Column(children:[
        Row(children:[
          ChoiceChip(label: Text("Products ${myP.length}"), selected: tab=="Prod", onSelected:(v)=>setState(()=>tab="Prod")),
          SizedBox(width:5),
          ChoiceChip(label: Text("Orders ${myO.length}"), selected: tab=="Ord", onSelected:(v)=>setState(()=>tab="Ord")),
          ChoiceChip(label: Text("Notifs ${myN.length}"), selected: tab=="Not", onSelected:(v)=>setState(()=>tab="Not")),
        ]),
        if(tab=="Prod") Expanded(child: Column(children:[
          ElevatedButton(onPressed:(){
            String n="",pr="",cat="Saree",st="10";
            showDialog(context: context, builder:(ctx)=>AlertDialog(title: Text("Add Product"), content: Column(mainAxisSize: MainAxisSize.min, children:[
              TextField(decoration: InputDecoration(labelText: "Name"), onChanged:(v)=>n=v),
              TextField(decoration: InputDecoration(labelText: "Price"), onChanged:(v)=>pr=v),
              TextField(decoration: InputDecoration(labelText: "Category"), onChanged:(v)=>cat=v),
              TextField(decoration: InputDecoration(labelText: "Stock"), controller: TextEditingController(text:"10"), onChanged:(v)=>st=v),
            ]), actions:[ TextButton(onPressed:(){ var u=USERS.firstWhere((e)=>e.id==widget.sId); setState(()=>PRODS.add(Product(DateTime.now().millisecondsSinceEpoch.toString(),n,pr,cat,widget.sId,widget.sName,u.phone,stock:int.tryParse(st)??10,isApproved:false))); Navigator.pop(ctx); }, child: Text("Add")) ]));
          }, child: Text("+ Add Product")),
          Expanded(child: ListView.builder(itemCount: myP.length, itemBuilder:(ctx,i){
            var p=myP[i];
            return Card(child: ListTile(leading: CircleAvatar(child: Text("${p.stock}")), title: Text("${p.name} - ₹${p.price} ${p.isApproved?"✅":"⏳"}"), subtitle: Text("Stock:${p.stock}"), trailing: Row(mainAxisSize: MainAxisSize.min, children:[
              IconButton(icon: Icon(Icons.edit,color:Colors.blue), onPressed:(){
                String n=p.name,pr=p.price,st=p.stock.toString();
                showDialog(context: context, builder:(ctx)=>AlertDialog(title: Text("Edit"), content: Column(mainAxisSize: MainAxisSize.min, children:[ TextField(controller: TextEditingController(text:n), onChanged:(v)=>n=v), TextField(controller: TextEditingController(text:pr), onChanged:(v)=>pr=v), TextField(controller: TextEditingController(text:st), onChanged:(v)=>st=v) ]), actions:[ TextButton(onPressed:(){ setState(()=>{p.name=n,p.price=pr,p.stock=int.tryParse(st)??0,p.inStock=p.stock>0}); Navigator.pop(ctx); }, child: Text("Update")) ]));
              }),
              IconButton(icon: Icon(Icons.delete,color:Colors.red), onPressed:(){ setState(()=>PRODS.remove(p)); }),
            ])));
          }))
        ])),
        if(tab=="Ord") Expanded(child: ListView.builder(itemCount: myO.length, itemBuilder:(ctx,i){ var o=myO[i]; return Card(child: ListTile(title: Text(o.pName), subtitle: Text("Cust:${o.custName} | ₹${o.price}"))); })),
        if(tab=="Not") Expanded(child: ListView.builder(itemCount: myN.length, itemBuilder:(ctx,i){ var n=myN[i]; return Card(color: Colors.red[50], child: ListTile(title: Text(n.title), subtitle: Text("${n.msg}\n${n.date}"), trailing: IconButton(icon: Icon(Icons.add,color:Colors.green), onPressed:(){ var p=PRODS.where((pr)=>pr.id==n.pId).toList(); if(p.isNotEmpty) setState(()=>{p[0].stock+=10,p[0].inStock=true}); }))); })),
      ])
    );
  }
}

class AdminPanel extends StatefulWidget { String adminNum; AdminPanel({required this.adminNum}); @override _AdminPanelState createState()=>_AdminPanelState(); }
class _AdminPanelState extends State<AdminPanel> {
  String tab="Users";
  @override Widget build(BuildContext c){
    return Scaffold(appBar: AppBar(title: Text("ADMIN ${widget.adminNum} ✅"), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: Column(children:[
        Container(color: Colors.red[100], padding: EdgeInsets.all(8), child: Text("ADMIN OTP VERIFIED: ${widget.adminNum} - Yahan sabke Number, Aadhar, Account dikhenge",style: TextStyle(fontSize:10,fontWeight:FontWeight.bold))),
        Row(children:[
          ChoiceChip(label: Text("Users ${USERS.length}"), selected: tab=="Users", onSelected:(v)=>setState(()=>tab="Users")),
          ChoiceChip(label: Text("Products ${PRODS.length}"), selected: tab=="Products", onSelected:(v)=>setState(()=>tab="Products")),
          ChoiceChip(label: Text("Orders ${ORDERS.length}"), selected: tab=="Orders", onSelected:(v)=>setState(()=>tab="Orders")),
          ChoiceChip(label: Text("Notifs ${ADMIN_NOTIFS.length}"), selected: tab=="Notifs", onSelected:(v)=>setState(()=>tab="Notifs")),
        ]),
        if(tab=="Users") Expanded(child: ListView.builder(itemCount: USERS.length, itemBuilder:(ctx,i){
          var u=USERS[i];
          return Card(child: ExpansionTile(title: Text("${u.name} - ${u.isSeller?"SELLER":"CUSTOMER"} ${u.isApproved?"✅":"⏳"}"), subtitle: Text("Phone:${u.phone} - ADMIN ONLY | ID:${u.id}",style: TextStyle(fontSize:10,fontWeight:FontWeight.bold)),
            children:[ Padding(padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Container(color: Colors.red[50], padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text("🔒 ADMIN ONLY - FULL DATA:",style: TextStyle(fontWeight:FontWeight.bold,color:Colors.red,fontSize:11)),
                Text("📞 Phone:${u.phone}",style: TextStyle(fontWeight:FontWeight.bold)),
                Text("🏠 Address:${u.addr}"),
                if(u.isSeller)...[ Text("🏪 Shop:${u.shop}"), Text("🆔 Aadhar:${u.aadhar}"), Text("🏦 Account:${u.acc}"), Text("📱 PhonePe:${u.pe}") ]
              ])),
              Row(children:[
                if(!u.isApproved) ElevatedButton(onPressed:(){ setState(()=>u.isApproved=true); }, child: Text("Approve"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
                SizedBox(width:5),
                ElevatedButton(onPressed:(){ setState(()=>USERS.removeAt(i)); }, child: Text("Delete"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
              ])
            ]))
          ]);
        })),
        if(tab=="Products") Expanded(child: ListView.builder(itemCount: PRODS.length, itemBuilder:(ctx,i){
          var p=PRODS[i];
          return Card(child: ListTile(title: Text("${p.name} - ₹${p.price} ${p.isApproved?"✅":"⏳"}"), subtitle: Text("Seller:${p.sellerName} | Phone:${p.sellerPhone} | Stock:${p.stock}"), trailing: Row(mainAxisSize: MainAxisSize.min, children:[
            if(!p.isApproved) IconButton(icon: Icon(Icons.check,color:Colors.green), onPressed:(){ setState(()=>p.isApproved=true); }),
            IconButton(icon: Icon(Icons.delete,color:Colors.red), onPressed:(){ setState(()=>PRODS.removeAt(i)); }),
          ])));
        })),
        if(tab=="Orders") Expanded(child: ListView.builder(itemCount: ORDERS.length, itemBuilder:(ctx,i){
          var o=ORDERS[i];
          return Card(child: ListTile(title: Text("${o.pName} - ₹${o.price}"), subtitle: Text("Customer:${o.custName} | Phone:${o.custPhone} | Seller:${o.sellerId} | ${o.date}"),));
        })),
        if(tab=="Notifs") Expanded(child: ListView.builder(itemCount: ADMIN_NOTIFS.length, itemBuilder:(ctx,i){
          var n=ADMIN_NOTIFS[i];
          return Card(color: Colors.red[50], child: ListTile(title: Text(n.title), subtitle: Text("${n.msg}\n${n.date}"), trailing: IconButton(icon: Icon(Icons.delete,color:Colors.red), onPressed:(){ setState(()=>ADMIN_NOTIFS.removeAt(i)); })));
        })),
      ])
    );
  }
}
