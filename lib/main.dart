import 'package:flutter/material.dart';
void main() { runApp(MyApp()); }
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}
class Product { String name, shop; double price; bool ok; Product(this.name, this.shop, this.price, this.ok); }
List<Product> allProducts = [ Product("Saree", "Avira", 349, true), Product("Kurti", "Style Hub", 499, true) ];
List<Product> cart = [];
String adminNumber = "8955116739";
String inputNumber = "";
List<Map> sellers = [];

class MainPage extends StatefulWidget { @override _MainPageState createState() => _MainPageState(); }
class _MainPageState extends State<MainPage> {
  int i = 0;
  Widget build(BuildContext c) {
    List<Widget> pages = [ HomePage(), SellerPage(), CartPage(), ProfilePage() ];
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(currentIndex: i, selectedItemColor: Color(0xFF9F2089), unselectedItemColor: Colors.grey, onTap: (x){ setState((){ i = x; }); }, type: BottomNavigationBarType.fixed, items: [ BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.store), label: "Seller"), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"), BottomNavigationBarItem(icon: Icon(Icons.person), label: "You") ]),
    );
  }
}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text("Avira Store", style: TextStyle(color: Color(0xFF9F2089), fontWeight: FontWeight.bold)), backgroundColor: Colors.white), body: GridView.builder(padding: EdgeInsets.all(8), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: allProducts.length, itemBuilder: (ctx, index){ var p = allProducts[index]; if(!p.ok) return SizedBox(); return Card(child: Column(children: [ Expanded(child: Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image, size: 40)))), Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(p.shop, style: TextStyle(fontSize: 10, color: Color(0xFF9F2089))), Text(p.name, style: TextStyle(fontSize: 13)), Text("₹${p.price.toInt()}", style: TextStyle(fontWeight: FontWeight.bold)), Text("Free Delivery", style: TextStyle(fontSize: 10, color: Colors.green)) ])) ])); }));
  }
}
class SellerPage extends StatefulWidget { @override _SellerPageState createState() => _SellerPageState(); }
class _SellerPageState extends State<SellerPage> {
  String sName = "", sNum = "", pName = "", pPrice = "";
  bool reg = false;
  @override
  Widget build(BuildContext c) {
    if(!reg){ return Scaffold(appBar: AppBar(title: Text("Become Seller")), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [ Icon(Icons.store, size: 80, color: Color(0xFF9F2089)), Text("Avira Pe Becho"), SizedBox(height: 20), TextField(decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder()), onChanged: (v){ sName = v; }), SizedBox(height: 10), TextField(decoration: InputDecoration(labelText: "Number", border: OutlineInputBorder()), onChanged: (v){ sNum = v; }), SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white), onPressed: (){ sellers.add({"name": sName, "number": sNum}); setState((){ reg = true; }); }, child: Text("Register")) ) ]))); }
    return Scaffold(appBar: AppBar(title: Text("Seller Panel")), body: Padding(padding: EdgeInsets.all(16), child: Column(children: [ TextField(decoration: InputDecoration(labelText: "Product Name"), onChanged: (v){ pName = v; }), TextField(decoration: InputDecoration(labelText: "Price"), onChanged: (v){ pPrice = v; }), ElevatedButton(onPressed: (){ allProducts.add(Product(pName, sName, double.tryParse(pPrice)?? 0, false)); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text("Sent to Admin 8955116739 for Approval"))); }, child: Text("Add Product")) ])));
  }
}
class CartPage extends StatelessWidget { @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text("Cart")), body: Center(child: Text("Cart: ${cart.length} items"))); } }
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text("You")), body: ListView(children: [ ListTile(title: Text("Vikky Owner"), subtitle: Text("Admin: 8955116739")), ListTile(leading: Icon(Icons.admin_panel_settings), title: Text("Admin Panel"), subtitle: Text("Only 8955116739"), onTap: (){ showDialog(context: c, builder: (ctx){ return AlertDialog(title: Text("Admin Login"), content: TextField(decoration: InputDecoration(hintText: "Enter 8955116739"), onChanged: (v){ inputNumber = v; }), actions: [ TextButton(onPressed: (){ if(inputNumber == adminNumber){ Navigator.pop(ctx); Navigator.push(c, MaterialPageRoute(builder: (c){ return AdminPage(); })); } else { ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text("Wrong Number! Only 8955116739"))); } }, child: Text("Login")) ]); }); }) ]));
  }
}
class AdminPage extends StatefulWidget { @override _AdminPageState createState() => _AdminPageState(); }
class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext c) {
    return Scaffold(appBar: AppBar(title: Text("ADMIN - 8955116739 ONLY"), backgroundColor: Color(0xFF9F2089), foregroundColor: Colors.white), body: ListView(children: [ Padding(padding: EdgeInsets.all(10), child: Text("Products Approval", style: TextStyle(fontWeight: FontWeight.bold))),...allProducts.map((p){ return Card(child: ListTile(title: Text(p.name), subtitle: Text("${p.shop} - ₹${p.price}"), trailing: p.ok? Text("Approved") : ElevatedButton(onPressed: (){ setState((){ p.ok = true; }); }, child: Text("Approve")))); }).toList() ]));
  }
}
