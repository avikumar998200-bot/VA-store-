import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(AviraApp());
}

class AviraApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class AdminSecure {
  static const String adminNum = '8955116739';
  static String otp = '';
  static String genOTP() {
    otp = (100000 + Random().nextInt(900000)).toString();
    return otp;
  }
  static bool verify(String n, String o) {
    return n.trim() == adminNum && o == otp;
  }
  static bool isAdmin(String n) {
    return n.trim() == adminNum;
  }
}

class AdminPay {
  static String phonePe = '8955116739';
  static String account = '1234567890 SBI IFSC SBIN0001';
  static String upi = 'vikky@upi';
  static String gpay = '8955116739';
  static double commission = 10.0;
}

class UserModel {
  String id; String name; String phone; String addr;
  String aadhar; String acc; String pe; String shop;
  bool isSeller; bool isApproved;
  double pending; double earned;
  UserModel(this.id, this.name, this.phone, this.addr,
      {this.isSeller = false, this.isApproved = false, this.aadhar = '', this.acc = '', this.pe = '', this.shop = '', this.pending = 0, this.earned = 0});
}

class Product {
  String id; String name; String price; String cat;
  String sellerId; String sellerName; String sellerPhone;
  String sellerAcc; String sellerPe;
  int stock; bool inStock; bool isApproved;
  Product(this.id, this.name, this.price, this.cat, this.sellerId, this.sellerName, this.sellerPhone,
      {this.stock = 10, this.inStock = true, this.isApproved = false, this.sellerAcc = '', this.sellerPe = ''});
}

class Order {
  String id; String pName; String price; String date;
  String custId; String custName; String custPhone; String sellerId;
  String status; String payMethod;
  double comm; double payout; bool isPaid;
  Order(this.id, this.pName, this.price, this.date, this.custId, this.custName, this.custPhone, this.sellerId,
      {this.status = 'Paid to Admin', this.payMethod = 'UPI to Admin', this.comm = 0, this.payout = 0, this.isPaid = false});
}

class CartItem { String pId; int qty; CartItem(this.pId, this.qty); }
class Notif { String id; String title; String msg; String date; String pId; String sId; Notif(this.id, this.title, this.msg, this.date, this.pId, this.sId); }

List<UserModel> USERS = [];
List<Product> PRODS = [];
List<Order> ORDERS = [];
List<Notif> ADMIN_NOTIFS = [];
List<Notif> SELLER_NOTIFS = [];
List<CartItem> CART = [];
String? L_ID; String? L_NAME;

class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }
class _MainScreenState extends State<MainScreen> {
  int idx = 0;
  @override Widget build(BuildContext c) {
    return Scaffold(
      body: [HomeScreen(), SearchScreen(), CartScreen(), YouScreen()][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, selectedItemColor: Color(0xFF9F2089),
        onTap: (v) => setState(() => idx = v),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  String cat = 'All';
  void openPay(Product p) {
    String method = 'UPI to Admin';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
      title: Text('Pay to Admin'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(color: Colors.red[50], padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Paisa Sidha Admin Ke Paas Jayega', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
          Text('PhonePe: ${AdminPay.phonePe}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Text('Account: ${AdminPay.account}', style: TextStyle(fontSize: 11)),
          Text('UPI: ${AdminPay.upi}', style: TextStyle(fontSize: 11)),
        ])),
        SizedBox(height: 10),
        Text('Product: ${p.name} Price: Rs.${p.price}'),
        RadioListTile(value: 'UPI to Admin', groupValue: method, title: Text('UPI PhonePe GPay Admin ko', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
        RadioListTile(value: 'Bank to Admin', groupValue: method, title: Text('Bank Transfer Admin Account', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
        RadioListTile(value: 'COD to Admin', groupValue: method, title: Text('COD Admin collect', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); doBuy(p, method); }, child: Text('Pay Rs.${p.price} to Admin'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white))
      ],
    )));
  }
  void doBuy(Product p, String method) {
    if (L_ID == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle Login You tab'))); return; }
    if (!p.inStock || p.stock <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Out of Stock'), backgroundColor: Colors.red)); return; }
    setState(() => p.stock--);
    if (p.stock <= 0) p.inStock = false;
    var u = USERS.firstWhere((e) => e.id == L_ID, orElse: () => UserModel('g', 'Guest', '', ''));
    double price = double.tryParse(p.price)?? 0;
    double comm = price * AdminPay.commission / 100;
    double payout = price - comm;
    ORDERS.add(Order(DateTime.now().millisecondsSinceEpoch.toString(), p.name, p.price, '${DateTime.now().day}-${DateTime.now().month}', L_ID!, L_NAME!, u.phone, p.sellerId, payMethod: method, comm: comm, payout: payout, isPaid: false, status: 'Paid to Admin'));
    var seller = USERS.where((x) => x.id == p.sellerId).toList();
    if (seller.isNotEmpty) seller[0].pending += payout;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paid Rs.${p.price} to Admin Seller ko Rs.$payout Admin bhejega'), backgroundColor: Colors.green));
  }
  @override Widget build(BuildContext c) {
    var list = PRODS.where((p) => p.isApproved && (cat == 'All' || p.cat == cat)).toList();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text('Avira Pay to Admin', style: TextStyle(color: Color(0xFF9F2089), fontWeight: FontWeight.bold, fontSize: 14))),
      body: Column(children: [
        Container(color: Colors.red[100], padding: EdgeInsets.all(6), child: Text('Sab Paisa Admin ke paas ${AdminPay.phonePe} Admin change kar sakta hai', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['All', 'Saree', 'Kurti', 'Lehenga', 'Suits'].map((e) => Padding(padding: EdgeInsets.all(4), child: ChoiceChip(label: Text(e), selected: cat == e, onSelected: (v) => setState(() => cat = e)))).toList())),
        Expanded(child: list.isEmpty? Center(child: Text('No Products')) : GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: list.length, itemBuilder: (ctx, i) {
          var p = list[i];
          return Card(child: Column(children: [
            Expanded(child: Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image)))),
            Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text('By ${p.sellerName}', style: TextStyle(fontSize: 9, color: Color(0xFF9F2089))),
              Text('Rs.${p.price} Stock ${p.stock}', style: TextStyle(fontSize: 11, color: p.inStock? Colors.green : Colors.red)),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => openPay(p), child: Text(p.inStock? 'Pay to Admin' : 'Out', style: TextStyle(fontSize: 8)), style: ElevatedButton.styleFrom(backgroundColor: p.inStock? Color(0xFF9F2089) : Colors.grey, foregroundColor: Colors.white)))
            ]))
          ]));
        }))
      ]),
    );
  }
}

class SearchScreen extends StatefulWidget { @override _SearchScreenState createState() => _SearchScreenState(); }
class _SearchScreenState extends State<SearchScreen> {
  String q = '';
  @override Widget build(BuildContext c) {
    var list = PRODS.where((p) => p.isApproved && p.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(appBar: AppBar(title: Text('Search'), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white), body: Column(children: [
      Padding(padding: EdgeInsets.all(10), child: TextField(decoration: InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: (v) => setState(() => q = v))),
      Expanded(child: ListView.builder(itemCount: list.length, itemBuilder: (ctx, i) { var p = list[i]; return Card(child: ListTile(title: Text('${p.name} Rs.${p.price}'), subtitle: Text('By ${p.sellerName} Stock ${p.stock}'))); }))
    ]));
  }
}

class CartScreen extends StatefulWidget { @override _CartScreenState createState() => _CartScreenState(); }
class _CartScreenState extends State<CartScreen> {
  @override Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text('Cart'), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white), body: Center(child: Text('Cart - Pay to Admin ${AdminPay.phonePe}')));
  }
}

class YouScreen extends StatefulWidget { @override _YouScreenState createState() => _YouScreenState(); }
class _YouScreenState extends State<YouScreen> {
  void adminOTP() {
    String num = ''; String otp = ''; String gen = '';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
      title: Text('Admin OTP Login'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(labelText: 'Admin Number 8955116739', border: OutlineInputBorder()), onChanged: (v) => num = v),
        if (gen.isNotEmpty)...[ Container(color: Colors.green[50], padding: EdgeInsets.all(8), child: Text('OTP $gen')), TextField(decoration: InputDecoration(labelText: 'OTP', border: OutlineInputBorder()), onChanged: (v) => otp = v) ]
      ]),
      actions: [
        if (gen.isEmpty) TextButton(onPressed: () { if (!AdminSecure.isAdmin(num)) return; String o = AdminSecure.genOTP(); setSt(() => gen = o); }, child: Text('Send OTP')),
        if (gen.isNotEmpty) TextButton(onPressed: () { if (AdminSecure.verify(num, otp)) { Navigator.pop(ctx); L_ID = 'ADMIN'; L_NAME = 'Admin'; Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel(adminNum: num))); } }, child: Text('Verify'))
      ],
    )));
  }
  void userLogin(bool seller) {
    String name = ''; String phone = ''; String addr = ''; String acc = ''; String pe = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(seller? 'Seller Registration' : 'Customer Registration'),
      content: SingleChildScrollView(child: Column(children: [
        TextField(decoration: InputDecoration(labelText: 'Name*', border: OutlineInputBorder()), onChanged: (v) => name = v),
        TextField(decoration: InputDecoration(labelText: 'Phone*', border: OutlineInputBorder()), onChanged: (v) => phone = v),
        if (seller)...[ TextField(decoration: InputDecoration(labelText: 'Account Number* Admin yahan bhejega', border: OutlineInputBorder()), onChanged: (v) => acc = v), TextField(decoration: InputDecoration(labelText: 'PhonePe* Admin yahan bhejega', border: OutlineInputBorder()), onChanged: (v) => pe = v) ]
      ])),
      actions: [ TextButton(onPressed: () { if (name.isEmpty || phone.isEmpty) return; if (seller && (acc.isEmpty || pe.isEmpty)) return; String id = 'U_${DateTime.now().millisecondsSinceEpoch}'; USERS.add(UserModel(id, name, phone, addr, isSeller: seller, acc: acc, pe: pe)); L_ID = id; L_NAME = name; Navigator.pop(ctx); if (seller) Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPanel(sId: id, sName: name))); setState(() {}); }, child: Text('Register')) ],
    ));
  }
  @override Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text('You Avira')), body: Column(children: [
      Card(color: Colors.red[50], child: ListTile(leading: Icon(Icons.admin_panel_settings, color: Colors.red), title: Text('Admin Login OTP 8955116739'), subtitle: Text('Paisa Admin ke paas ${AdminPay.phonePe}'), onTap: adminOTP)),
      ListTile(leading: Icon(Icons.person, color: Colors.blue), title: Text('Customer Login'), onTap: () => userLogin(false)),
      ListTile(leading: Icon(Icons.store, color: Colors.green), title: Text('Seller Login Account PhonePe'), onTap: () => userLogin(true)),
    ]));
  }
}

class SellerPanel extends StatefulWidget { String sId; String sName; SellerPanel({required this.sId, required this.sName}); @override _SellerPanelState createState() => _SellerPanelState(); }
class _SellerPanelState extends State<SellerPanel> {
  String tab = 'Prod';
  @override Widget build(BuildContext c) {
    var myP = PRODS.where((p) => p.sellerId == widget.sId).toList();
    var myO = ORDERS.where((o) => o.sellerId == widget.sId).toList();
    var me = USERS.where((u) => u.id == widget.sId).toList();
    double pending = me.isNotEmpty? me[0].pending : 0;
    return Scaffold(appBar: AppBar(title: Text('Seller ${widget.sName}'), backgroundColor: Colors.green, foregroundColor: Colors.white), body: Column(children: [
      Container(color: Colors.green[100], padding: EdgeInsets.all(8), child: Text(me.isNotEmpty? 'Account ${me[0].acc} PhonePe ${me[0].pe} Pending Rs.$pending' : '', style: TextStyle(fontSize: 11))),
      Row(children: [ ChoiceChip(label: Text('Products ${myP.length}'), selected: tab == 'Prod', onSelected: (v) => setState(() => tab = 'Prod')), SizedBox(width: 5), ChoiceChip(label: Text('Orders ${myO.length}'), selected: tab == 'Ord', onSelected: (v) => setState(() => tab = 'Ord')) ]),
      if (tab == 'Prod') Expanded(child: Column(children: [
        ElevatedButton(onPressed: () { String n = ''; String pr = ''; String st = '10'; String acc = ''; String pe = ''; var user = USERS.firstWhere((e) => e.id == widget.sId, orElse: () => UserModel('', '', '', '')); acc = user.acc; pe = user.pe; showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Add Product'), content: Column(mainAxisSize: MainAxisSize.min, children: [ TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()), onChanged: (v) => n = v), TextField(decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()), onChanged: (v) => pr = v), TextField(decoration: InputDecoration(labelText: 'Account', border: OutlineInputBorder()), controller: TextEditingController(text: acc), onChanged: (v) => acc = v), TextField(decoration: InputDecoration(labelText: 'PhonePe', border: OutlineInputBorder()), controller: TextEditingController(text: pe), onChanged: (v) => pe = v) ]), actions: [ TextButton(onPressed: () { var u = USERS.firstWhere((e) => e.id == widget.sId); setState(() => PRODS.add(Product(DateTime.now().millisecondsSinceEpoch.toString(), n, pr, 'Saree', widget.sId, widget.sName, u.phone, stock: int.tryParse(st)?? 10, sellerAcc: acc.isEmpty? u.acc : acc, sellerPe: pe.isEmpty? u.pe : pe))); Navigator.pop(ctx); }, child: Text('Add')) ])); }, child: Text('Add Product')),
        Expanded(child: ListView.builder(itemCount: myP.length, itemBuilder: (ctx, i) { var p = myP[i]; return Card(child: ListTile(title: Text('${p.name} Rs.${p.price}'), subtitle: Text('Acc ${p.sellerAcc} Pe ${p.sellerPe}'), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => PRODS.remove(p))))); }))
      ])),
      if (tab == 'Ord') Expanded(child: ListView.builder(itemCount: myO.length, itemBuilder: (ctx, i) { var o = myO[i]; return Card(child: ListTile(title: Text('${o.pName} Rs.${o.price}'), subtitle: Text('Pay ${o.payMethod} Comm Rs.${o.comm} You Rs.${o.payout}'))); }))
    ]));
  }
}

class AdminPanel extends StatefulWidget { String adminNum; AdminPanel({required this.adminNum}); @override _AdminPanelState createState() => _AdminPanelState(); }
class _AdminPanelState extends State<AdminPanel> {
  String tab = 'Orders';
  @override Widget build(BuildContext c) {
    double totalSale = ORDERS.fold(0, (s, o) => s + (double.tryParse(o.price)?? 0));
    double totalComm = ORDERS.fold(0, (s, o) => s + o.comm);
    double pendingPayout = ORDERS.where((o) =>!o.isPaid).fold(0, (s, o) => s + o.payout);
    return Scaffold(appBar: AppBar(title: Text('ADMIN ${widget.adminNum}'), backgroundColor: Colors.red, foregroundColor: Colors.white), body: Column(children: [
      Container(color: Colors.red[100], padding: EdgeInsets.all(8), child: Text('Paisa Admin ${AdminPay.phonePe} ${AdminPay.account} Sale Rs.$totalSale Comm Rs.$totalComm Pending Rs.$pendingPayout', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        ChoiceChip(label: Text('Settings'), selected: tab == 'Settings', onSelected: (v) => setState(() => tab = 'Settings')),
        ChoiceChip(label: Text('Orders ${ORDERS.length}'), selected: tab == 'Orders', onSelected: (v) => setState(() => tab = 'Orders')),
        ChoiceChip(label: Text('Users ${USERS.length}'), selected: tab == 'Users', onSelected: (v) => setState(() => tab = 'Users')),
        ChoiceChip(label: Text('Products ${PRODS.length}'), selected: tab == 'Products', onSelected: (v) => setState(() => tab = 'Products')),
      ])),
      if (tab == 'Settings') Expanded(child: ListView(children: [
        Card(child: Padding(padding: EdgeInsets.all(12), child: Column(children: [
          TextField(controller: TextEditingController(text: AdminPay.phonePe), decoration: InputDecoration(labelText: 'Admin PhonePe Customer yahan bhejega', border: OutlineInputBorder()), onChanged: (v) => AdminPay.phonePe = v),
          SizedBox(height: 8),
          TextField(controller: TextEditingController(text: AdminPay.account), decoration: InputDecoration(labelText: 'Admin Account Bank IFSC', border: OutlineInputBorder()), onChanged: (v) => AdminPay.account = v),
          SizedBox(height: 8),
          TextField(controller: TextEditingController(text: '${AdminPay.commission}'), decoration: InputDecoration(labelText: 'Commission %', border: OutlineInputBorder()), onChanged: (v) => AdminPay.commission = double.tryParse(v)?? 10),
          ElevatedButton(onPressed: () { setState(() {}); }, child: Text('Save')),
        ]))),
        Card(child: ListTile(title: Text('Auto Pay to Sellers'), trailing: ElevatedButton(onPressed: () { for (var o in ORDERS.where((x) =>!x.isPaid)) { o.isPaid = true; var seller = USERS.where((u) => u.id == o.sellerId).toList(); if (seller.isNotEmpty) { seller[0].pending -= o.payout; if (seller[0].pending < 0) seller[0].pending = 0; seller[0].earned += o.payout; } } setState(() {}); }, child: Text('Auto Pay Rs.$pendingPayout')))),
      ])),
      if (tab == 'Orders') Expanded(child: ListView.builder(itemCount: ORDERS.length, itemBuilder: (ctx, i) { var o = ORDERS[i]; return Card(color: o.isPaid? Colors.green[50] : Colors.orange[50], child: ExpansionTile(title: Text('${o.pName} Rs.${o.price} ${o.isPaid? "Paid Seller" : "Pending Admin"}'), subtitle: Text('Cust ${o.custName} Comm Rs.${o.comm} Seller Rs.${o.payout}'), children: [ if (!o.isPaid) ElevatedButton(onPressed: () { setState(() { o.isPaid = true; var s = USERS.where((u) => u.id == o.sellerId).toList(); if (s.isNotEmpty) { s[0].pending -= o.payout; if (s[0].pending < 0) s[0].pending = 0; s[0].earned += o.payout; } }); }, child: Text('Pay Seller Rs.${o.payout} Manual'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)) ])); })),
      if (tab == 'Users') Expanded(child: ListView.builder(itemCount: USERS.length, itemBuilder: (ctx, i) { var u = USERS[i]; return Card(child: ListTile(title: Text('${u.name} ${u.isSeller? "SELLER" : "CUSTOMER"}'), subtitle: Text('Phone ${u.phone} Acc ${u.acc} Pe ${u.pe} Pending Rs.${u.pending}'), trailing: u.isSeller && u.pending > 0? ElevatedButton(onPressed: () { setState(() { for (var o in ORDERS.where((x) => x.sellerId == u.id &&!x.isPaid)) { o.isPaid = true; } u.earned += u.pending; u.pending = 0; }); }, child: Text('Pay Rs.${u.pending}')) : null)); })),
      if (tab == 'Products') Expanded(child: ListView.builder(itemCount: PRODS.length, itemBuilder: (ctx, i) { var p = PRODS[i]; return Card(child: ListTile(title: Text('${p.name} Rs.${p.price} ${p.isApproved? "Approved" : "Pending"}'), subtitle: Text('Seller ${p.sellerName} Acc ${p.sellerAcc} Pe ${p.sellerPe}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [ if (!p.isApproved) IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => setState(() => p.isApproved = true)), IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => PRODS.removeAt(i))) ]))); })),
    ]));
  }
}
