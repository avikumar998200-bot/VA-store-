import 'dart:math';
import 'package:flutter/material.dart';

void main() { runApp(AviraApp()); }

class AviraApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}

// ADMIN NUMBER - CODE ME HAI, UI ME KAHI PUBLIC NAHI DIKHEGA
class AdminSecure {
  static const String adminNum = '8955116739';
  static String otp = '';
  static String genOTP() {
    otp = (100000 + Random().nextInt(900000)).toString();
    return otp;
  }
  static bool verify(String n, String o) => n.trim() == adminNum && o == otp;
  static bool isAdmin(String n) => n.trim() == adminNum;
}

class AdminPay {
  static String phonePe = '8955116739';
  static String account = '1234567890 SBI IFSC SBIN0001';
  static String upi = 'vikky@upi';
  static double commission = 10.0;
}

class UserModel {
  String id; String name; String phone; String addr;
  String acc; String pe; bool isSeller; bool isApproved;
  double pending; double earned;
  UserModel(this.id, this.name, this.phone, this.addr, {this.isSeller = false, this.isApproved = false, this.acc = '', this.pe = '', this.pending = 0, this.earned = 0});
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
  String status; String payMethod; double comm; double payout; bool isPaid;
  Order(this.id, this.pName, this.price, this.date, this.custId, this.custName, this.custPhone, this.sellerId,
      {this.status = 'Paid to Admin', this.payMethod = 'UPI to Admin', this.comm = 0, this.payout = 0, this.isPaid = false});
}

class CartItem { String pId; int qty; CartItem(this.pId, this.qty); }
class Notif { String id; String title; String msg; String date; String pId; String sId; Notif(this.id, this.title, this.msg, this.date, this.pId, this.sId); }

List<UserModel> USERS = [];
List<Product> PRODS = [
  Product('1', 'Red Saree', '999', 'Saree', 'demo', 'Avira Store', '0000000000', stock: 20, isApproved: true, sellerAcc: 'demo', sellerPe: 'demo'),
  Product('2', 'Designer Kurti', '599', 'Kurti', 'demo', 'Avira Store', '0000000000', stock: 15, isApproved: true, sellerAcc: 'demo', sellerPe: 'demo'),
];
List<Order> ORDERS = [];
List<Notif> ADMIN_NOTIFS = [];
List<Notif> SELLER_NOTIFS = [];
List<CartItem> CART = [];
String? L_ID; String? L_NAME;

class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }
class _MainScreenState extends State<MainScreen> {
  int idx = 0;
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: [HomeScreen(), SearchScreen(), CartScreen(), YouScreen()][idx],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // FIX - Icons dikhenge ab
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Color(0xFF9F2089),
        unselectedItemColor: Colors.grey,
        currentIndex: idx,
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
    String method = 'UPI';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
      title: Text('Secure Payment'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(color: Colors.green[50], padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('100% Secure Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
          Text('Payment Admin dwara secure hai', style: TextStyle(fontSize: 11)),
        ])),
        SizedBox(height: 10),
        Text('Product: ${p.name}'), Text('Price: Rs.${p.price} Seller: ${p.sellerName}', style: TextStyle(fontSize: 11)),
        SizedBox(height: 10),
        RadioListTile(value: 'UPI', groupValue: method, title: Text('UPI / PhonePe / GPay', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
        RadioListTile(value: 'Bank', groupValue: method, title: Text('Bank Transfer', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
        RadioListTile(value: 'COD', groupValue: method, title: Text('Cash on Delivery', style: TextStyle(fontSize: 11)), onChanged: (v) => setSt(() => method = v.toString())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); doBuy(p, method); }, child: Text('Pay Rs.${p.price}'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white))
      ],
    )));
  }
  void doBuy(Product p, String method) {
    if (L_ID == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pehle Login - You tab me'))); return; }
    if (!p.inStock || p.stock <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Out of Stock'), backgroundColor: Colors.red)); return; }
    setState(() => p.stock--);
    if (p.stock <= 0) p.inStock = false;
    var u = USERS.firstWhere((e) => e.id == L_ID, orElse: () => UserModel('g', 'Guest', '', ''));
    double price = double.tryParse(p.price)?? 0;
    double comm = price * AdminPay.commission / 100;
    double payout = price - comm;
    ORDERS.add(Order(DateTime.now().millisecondsSinceEpoch.toString(), p.name, p.price, '${DateTime.now().day}-${DateTime.now().month}', L_ID!, L_NAME!, u.phone, p.sellerId, payMethod: method, comm: comm, payout: payout, isPaid: false));
    var seller = USERS.where((x) => x.id == p.sellerId).toList();
    if (seller.isNotEmpty) seller[0].pending += payout;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Placed Securely!'), backgroundColor: Colors.green));
  }
  @override Widget build(BuildContext c) {
    var list = PRODS.where((p) => p.isApproved && (cat == 'All' || p.cat == cat)).toList();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text('Avira Store', style: TextStyle(color: Color(0xFF9F2089), fontWeight: FontWeight.bold))),
      body: Column(children: [
        Container(color: Colors.green[50], padding: EdgeInsets.all(8), child: Row(children: [Icon(Icons.verified_user, color: Colors.green, size: 16), SizedBox(width: 5), Text('100% Secure Shopping - Trusted by Avira', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))])), // NUMBER HATA DIYA
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['All', 'Saree', 'Kurti', 'Lehenga', 'Suits'].map((e) => Padding(padding: EdgeInsets.all(4), child: ChoiceChip(label: Text(e), selected: cat == e, onSelected: (v) => setState(() => cat = e)))).toList())),
        Expanded(child: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: list.length, itemBuilder: (ctx, i) {
          var p = list[i];
          return Card(child: Column(children: [
            Expanded(child: Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image, size: 40)))),
            Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text('By ${p.sellerName}', style: TextStyle(fontSize: 9, color: Color(0xFF9F2089))),
              Text('Rs.${p.price} Stock ${p.stock}', style: TextStyle(fontSize: 11, color: p.inStock? Colors.green : Colors.red)),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => openPay(p), child: Text(p.inStock? 'Buy Now' : 'Out', style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: p.inStock? Color(0xFF9F2089) : Colors.grey, foregroundColor: Colors.white)))
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
      Padding(padding: EdgeInsets.all(10), child: TextField(decoration: InputDecoration(hintText: 'Search products', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: (v) => setState(() => q = v))),
      Expanded(child: ListView.builder(itemCount: list.length, itemBuilder: (ctx, i) { var p = list[i]; return Card(child: ListTile(leading: Icon(Icons.shopping_bag), title: Text('${p.name} Rs.${p.price}'), subtitle: Text('By ${p.sellerName}'))); }))
    ]));
  }
}

class CartScreen extends StatefulWidget { @override _CartScreenState createState() => _CartScreenState(); }
class _CartScreenState extends State<CartScreen> {
  @override Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text('Cart'), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart, size: 60, color: Colors.grey), Text('Your Cart is Empty'), Text('Add products from Home', style: TextStyle(fontSize: 11, color: Colors.grey))])));
  }
}

class YouScreen extends StatefulWidget { @override _YouScreenState createState() => _YouScreenState(); }
class _YouScreenState extends State<YouScreen> {
  void adminOTP() {
    String num = ''; String otp = ''; String gen = '';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setSt) => AlertDialog(
      title: Text('Admin Login'), // NUMBER HATA DIYA
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Secure Admin Access Only', style: TextStyle(fontSize: 11, color: Colors.grey)),
        SizedBox(height: 10),
        TextField(decoration: InputDecoration(labelText: 'Enter Admin Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.admin_panel_settings)), keyboardType: TextInputType.phone, onChanged: (v) => num = v),
        if (gen.isNotEmpty)...[ SizedBox(height: 10), Container(color: Colors.green[50], padding: EdgeInsets.all(8), child: Text('OTP: $gen', style: TextStyle(fontWeight: FontWeight.bold))), TextField(decoration: InputDecoration(labelText: 'Enter OTP', border: OutlineInputBorder()), onChanged: (v) => otp = v) ]
      ]),
      actions: [
        if (gen.isEmpty) TextButton(onPressed: () { if (!AdminSecure.isAdmin(num)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Admin Number'), backgroundColor: Colors.red)); return; } String o = AdminSecure.genOTP(); setSt(() => gen = o); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP Generated: $o'))); }, child: Text('Send OTP')),
        if (gen.isNotEmpty) TextButton(onPressed: () { if (AdminSecure.verify(num, otp)) { Navigator.pop(ctx); L_ID = 'ADMIN'; L_NAME = 'Admin'; Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel(adminNum: num))); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong OTP'))); } }, child: Text('Verify'))
      ],
    )));
  }
  void userLogin(bool seller) {
    String name = ''; String phone = ''; String acc = ''; String pe = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(seller? 'Seller Registration' : 'Customer Registration'),
      content: SingleChildScrollView(child: Column(children: [
        TextField(decoration: InputDecoration(labelText: 'Full Name*', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), onChanged: (v) => name = v),
        SizedBox(height: 8),
        TextField(decoration: InputDecoration(labelText: 'Phone Number*', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone, onChanged: (v) => phone = v),
        if (seller)...[
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Bank Account Number*', border: OutlineInputBorder(), prefixIcon: Icon(Icons.account_balance)), onChanged: (v) => acc = v),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'PhonePe / GPay Number*', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payment)), onChanged: (v) => pe = v),
        ]
      ])),
      actions: [ TextButton(onPressed: () { if (name.isEmpty || phone.isEmpty) return; if (seller && (acc.isEmpty || pe.isEmpty)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account & PhonePe required'))); return; } String id = 'U_${DateTime.now().millisecondsSinceEpoch}'; USERS.add(UserModel(id, name, phone, '', isSeller: seller, acc: acc, pe: pe)); L_ID = id; L_NAME = name; Navigator.pop(ctx); if (seller) Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPanel(sId: id, sName: name))); setState(() {}); }, child: Text('Register')) ],
    ));
  }
  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('You - Avira'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: ListView(children: [
        Card(color: Colors.red[50], margin: EdgeInsets.all(10), child: ListTile(leading: Icon(Icons.admin_panel_settings, color: Colors.red, size: 30), title: Text('Admin Login', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Secure OTP Login - Only Admin Access'), trailing: Icon(Icons.lock, color: Colors.red), onTap: adminOTP)), // NUMBER HATA DIYA - AB SECURE
        Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Icon(Icons.person, color: Colors.blue)), title: Text('Customer Login'), subtitle: Text('Login as Customer to buy products'), trailing: Icon(Icons.arrow_forward_ios, size: 16), onTap: () => userLogin(false))),
        Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: CircleAvatar(backgroundColor: Colors.green[100], child: Icon(Icons.store, color: Colors.green)), title: Text('Seller Login'), subtitle: Text('Sell your products - Account & PhonePe required'), trailing: Icon(Icons.arrow_forward_ios, size: 16), onTap: () => userLogin(true))),
        SizedBox(height: 20),
        Padding(padding: EdgeInsets.all(10), child: Text('100% Secure - Your number is safe - Only Admin can see', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey))),
      ]),
    );
  }
}

class SellerPanel extends StatefulWidget { String sId; String sName; SellerPanel({required this.sId, required this.sName}); @override _SellerPanelState createState() => _SellerPanelState(); }
class _SellerPanelState extends State<SellerPanel> {
  String tab = 'Prod';
  @override Widget build(BuildContext c) {
    var myP = PRODS.where((p) => p.sellerId == widget.sId).toList();
    var myO = ORDERS.where((o) => o.sellerId == widget.sId).toList();
    return Scaffold(appBar: AppBar(title: Text('Seller ${widget.sName}'), backgroundColor: Colors.green, foregroundColor: Colors.white), body: Column(children: [
      Row(children: [ ChoiceChip(label: Text('Products'), selected: tab == 'Prod', onSelected: (v) => setState(() => tab = 'Prod')), SizedBox(width: 5), ChoiceChip(label: Text('Orders'), selected: tab == 'Ord', onSelected: (v) => setState(() => tab = 'Ord')) ]),
      if (tab == 'Prod') Expanded(child: Column(children: [
        Padding(padding: EdgeInsets.all(8), child: ElevatedButton(onPressed: () { String n = ''; String pr = ''; String acc = ''; String pe = ''; var user = USERS.firstWhere((e) => e.id == widget.sId); acc = user.acc; pe = user.pe; showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Add Product'), content: Column(mainAxisSize: MainAxisSize.min, children: [ TextField(decoration: InputDecoration(labelText: 'Product Name'), onChanged: (v) => n = v), TextField(decoration: InputDecoration(labelText: 'Price'), onChanged: (v) => pr = v), TextField(decoration: InputDecoration(labelText: 'Account'), controller: TextEditingController(text: acc), onChanged: (v) => acc = v), TextField(decoration: InputDecoration(labelText: 'PhonePe'), controller: TextEditingController(text: pe), onChanged: (v) => pe = v) ]), actions: [ TextButton(onPressed: () { var u = USERS.firstWhere((e) => e.id == widget.sId); setState(() => PRODS.add(Product(DateTime.now().millisecondsSinceEpoch.toString(), n, pr, 'Saree', widget.sId, widget.sName, u.phone, sellerAcc: acc.isEmpty? u.acc : acc, sellerPe: pe.isEmpty? u.pe : pe))); Navigator.pop(ctx); }, child: Text('Add')) ])); }, child: Text('Add Product'))),
        Expanded(child: ListView.builder(itemCount: myP.length, itemBuilder: (ctx, i) { var p = myP[i]; return Card(child: ListTile(title: Text('${p.name} Rs.${p.price}'), subtitle: Text('Stock ${p.stock} Acc ${p.sellerAcc}'), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => PRODS.remove(p))))); }))
      ])),
      if (tab == 'Ord') Expanded(child: ListView.builder(itemCount: myO.length, itemBuilder: (ctx, i) { var o = myO[i]; return Card(child: ListTile(title: Text('${o.pName} Rs.${o.price}'), subtitle: Text('Customer ${o.custName}'))); }))
    ]));
  }
}

class AdminPanel extends StatefulWidget { String adminNum; AdminPanel({required this.adminNum}); @override _AdminPanelState createState() => _AdminPanelState(); }
class _AdminPanelState extends State<AdminPanel> {
  String tab = 'Orders';
  @override Widget build(BuildContext c) {
    double totalSale = ORDERS.fold(0, (s, o) => s + (double.tryParse(o.price)?? 0));
    double pendingPayout = ORDERS.where((o) =>!o.isPaid).fold(0, (s, o) => s + o.payout);
    return Scaffold(appBar: AppBar(title: Text('ADMIN Panel'), backgroundColor: Colors.red, foregroundColor: Colors.white), body: Column(children: [
      Container(color: Colors.red[100], padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ADMIN SECURE - Only you can see numbers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 11)),
        Text('Your Number: ${AdminPay.phonePe} Account: ${AdminPay.account}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), // AB SIRF ADMIN PANEL ME DIKHEGA
        Text('Total Sale Rs.$totalSale Pending Payout Rs.$pendingPayout', style: TextStyle(fontSize: 10)),
      ])),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        ChoiceChip(label: Text('Settings'), selected: tab == 'Settings', onSelected: (v) => setState(() => tab = 'Settings')),
        ChoiceChip(label: Text('Orders'), selected: tab == 'Orders', onSelected: (v) => setState(() => tab = 'Orders')),
        ChoiceChip(label: Text('Users'), selected: tab == 'Users', onSelected: (v) => setState(() => tab = 'Users')),
        ChoiceChip(label: Text('Products'), selected: tab == 'Products', onSelected: (v) => setState(() => tab = 'Products')),
      ])),
      if (tab == 'Settings') Expanded(child: ListView(children: [
        Padding(padding: EdgeInsets.all(12), child: Column(children: [
          TextField(controller: TextEditingController(text: AdminPay.phonePe), decoration: InputDecoration(labelText: 'Admin PhonePe - Customer yahan bhejega (Only Admin dekhega)', border: OutlineInputBorder()), onChanged: (v) => AdminPay.phonePe = v),
          SizedBox(height: 8),
          TextField(controller: TextEditingController(text: AdminPay.account), decoration: InputDecoration(labelText: 'Admin Account', border: OutlineInputBorder()), onChanged: (v) => AdminPay.account = v),
          SizedBox(height: 8),
          ElevatedButton(onPressed: () => setState(() {}), child: Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white))
        ])),
        Card(child: ListTile(title: Text('Auto Pay All Sellers Rs.$pendingPayout'), trailing: ElevatedButton(onPressed: () { for (var o in ORDERS.where((x) =>!x.isPaid)) { o.isPaid = true; var seller = USERS.where((u) => u.id == o.sellerId).toList(); if (seller.isNotEmpty) { seller[0].pending -= o.payout; seller[0].earned += o.payout; } } setState(() {}); }, child: Text('Auto Pay')))),
      ])),
      if (tab == 'Orders') Expanded(child: ListView.builder(itemCount: ORDERS.length, itemBuilder: (ctx, i) { var o = ORDERS[i]; return Card(color: o.isPaid? Colors.green[50] : Colors.orange[50], child: ListTile(title: Text('${o.pName} Rs.${o.price} ${o.isPaid? "Paid" : "Pending"}'), subtitle: Text('Cust ${o.custName} Phone ${o.custPhone} - Seller Payout Rs.${o.payout} Acc ${USERS.where((u) => u.id == o.sellerId).isNotEmpty? USERS.firstWhere((u) => u.id == o.sellerId).acc : ""}'), trailing:!o.isPaid? ElevatedButton(onPressed: () { setState(() { o.isPaid = true; var s = USERS.where((u) => u.id == o.sellerId).toList(); if (s.isNotEmpty) { s[0].pending -= o.payout; s[0].earned += o.payout; } }); }, child: Text('Pay')) : null)); })),
      if (tab == 'Users') Expanded(child: ListView.builder(itemCount: USERS.length, itemBuilder: (ctx, i) { var u = USERS[i]; return Card(child: ExpansionTile(title: Text('${u.name} ${u.isSeller? "SELLER" : "CUSTOMER"}'), subtitle: Text('Phone ${u.phone} - ADMIN ONLY'), children: [ Padding(padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text('Phone: ${u.phone}', style: TextStyle(fontWeight: FontWeight.bold)), Text('Account: ${u.acc}'), Text('PhonePe: ${u.pe}'), Text('Pending: Rs.${u.pending}'), if (!u.isApproved) ElevatedButton(onPressed: () => setState(() => u.isApproved = true), child: Text('Approve')) ])) ])); })),
      if (tab == 'Products') Expanded(child: ListView.builder(itemCount: PRODS.length, itemBuilder: (ctx, i) { var p = PRODS[i]; return Card(child: ListTile(title: Text('${p.name} Rs.${p.price} ${p.isApproved? "Approved" : "Pending"}'), subtitle: Text('Seller ${p.sellerName} Phone ${p.sellerPhone}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [ if (!p.isApproved) IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => setState(() => p.isApproved = true)), IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => PRODS.removeAt(i))) ]))); })),
    ]));
  }
}
