import 'package:flutter/material.dart';

void main() => runApp(VAStoreApp());

List<Map<String, dynamic>> allProducts = [
  {'name': 'T-Shirt', 'price': 399, 'seller': 'Vikky', 'icon': Icons.checkroom},
  {'name': 'Shoes', 'price': 999, 'seller': 'Avi', 'icon': Icons.directions_run},
  {'name': 'Watch', 'price': 1499, 'seller': 'Vikky', 'icon': Icons.watch},
  {'name': 'Headphone', 'price': 799, 'seller': 'Avi', 'icon': Icons.headphones},
];

List<Map<String, dynamic>> cart = [];
List<Map<String, dynamic>> orders = [];

class VAStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

// LOGIN PAGE - SAB ROLE
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.store, size: 100, color: Colors.deepPurple),
          SizedBox(height: 10),
          Text('VA STORE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          Text('Admin | Seller | Customer', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 40),
          roleButton(context, 'ADMIN PANEL', Icons.admin_panel_settings, Colors.red, AdminHome()),
          roleButton(context, 'SELLER PANEL', Icons.storefront, Colors.orange, SellerHome()),
          roleButton(context, 'CUSTOMER SHOPPING', Icons.shopping_bag, Colors.deepPurple, CustomerHome()),
        ]),
      ),
    );
  }
  Widget roleButton(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return Container(margin: EdgeInsets.symmetric(vertical: 8, horizontal: 30), width: double.infinity, child: ElevatedButton.icon(icon: Icon(icon, color: Colors.white), label: Text(title, style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: color, padding: EdgeInsets.all(15)), onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page))));
  }
}

// CUSTOMER HOME
class CustomerHome extends StatefulWidget { @override _CustomerHomeState createState() => _CustomerHomeState(); }
class _CustomerHomeState extends State<CustomerHome> {
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VA Store - Shopping'), backgroundColor: Colors.deepPurple, actions: [
        Stack(children: [
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage(onUpdate: () => setState(() {}))))),
          if (cart.isNotEmpty) Positioned(right: 5, top: 5, child: CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text('${cart.length}', style: TextStyle(fontSize: 12, color: Colors.white)))),
        ])
      ]),
      body: GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75), itemCount: allProducts.length, itemBuilder: (ctx, i) => Card(elevation: 4, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(allProducts[i]['icon'], size: 60, color: Colors.deepPurple),
        Text(allProducts[i]['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        Text('₹${allProducts[i]['price']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        Text('Seller: ${allProducts[i]['seller']}', style: TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(height: 8),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple), onPressed: () { setState(() => cart.add(allProducts[i])); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${allProducts[i]['name']} Added!'))); }, child: Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 12)))
      ]))),
    );
  }
}

class CartPage extends StatelessWidget {
  final VoidCallback onUpdate;
  CartPage({required this.onUpdate});
  @override Widget build(BuildContext context) {
    int total = cart.fold(0, (s, e) => s + e['price'] as int);
    return Scaffold(
      appBar: AppBar(title: Text('My Cart'), backgroundColor: Colors.deepPurple),
      body: cart.isEmpty? Center(child: Text('Cart Khali Hai')) : Column(children: [
        Expanded(child: ListView.builder(itemCount: cart.length, itemBuilder: (_, i) => ListTile(leading: Icon(cart[i]['icon']), title: Text(cart[i]['name']), trailing: Text('₹${cart[i]['price']}')))),
        Container(padding: EdgeInsets.all(20), color: Colors.grey.shade200, child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total: ₹$total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
          SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () { orders.add({'items': List.from(cart), 'total': total, 'date': DateTime.now().toString()}); cart.clear(); onUpdate(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuccessPage())); }, child: Text('BUY NOW - ₹$total', style: TextStyle(color: Colors.white))))
        ]))
      ]),
    );
  }
}

class SuccessPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 100, color: Colors.green), Text('Order Success!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: Text('Home Jao'))]))); }

// SELLER PANEL
class SellerHome extends StatefulWidget { @override _SellerHomeState createState() => _SellerHomeState(); }
class _SellerHomeState extends State<SellerHome> {
  TextEditingController nameC = TextEditingController(); TextEditingController priceC = TextEditingController();
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seller Panel'), backgroundColor: Colors.orange),
      body: Padding(padding: EdgeInsets.all(15), child: Column(children: [
        Text('Add New Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextField(controller: nameC, decoration: InputDecoration(labelText: 'Product Name (ex: Jeans)')),
        TextField(controller: priceC, decoration: InputDecoration(labelText: 'Price (ex: 599)'), keyboardType: TextInputType.number),
        SizedBox(height: 10),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () { if (nameC.text.isNotEmpty && priceC.text.isNotEmpty) { setState(() { allProducts.add({'name': nameC.text, 'price': int.tryParse(priceC.text)?? 0, 'seller': 'You', 'icon': Icons.shopping_bag}); }); nameC.clear(); priceC.clear(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product Add Ho Gaya!'))); } }, child: Text('ADD PRODUCT', style: TextStyle(color: Colors.white))),
        Divider(),
        Text('My Products: ${allProducts.where((p) => p['seller'] == 'You').length}', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: ListView.builder(itemCount: allProducts.length, itemBuilder: (_, i) => ListTile(leading: Icon(allProducts[i]['icon']), title: Text(allProducts[i]['name']), subtitle: Text('₹${allProducts[i]['price']} - ${allProducts[i]['seller']}')))),
      ])),
    );
  }
}

// ADMIN PANEL
class AdminHome extends StatelessWidget {
  @override Widget build(BuildContext context) {
    int totalSale = orders.fold(0, (s, e) => s + e['total'] as int);
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel'), backgroundColor: Colors.red),
      body: Padding(padding: EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          adminCard('Total Products', '${allProducts.length}', Colors.blue),
          adminCard('Total Orders', '${orders.length}', Colors.green),
        ]),
        Row(children: [
          adminCard('Total Sale', '₹$totalSale', Colors.orange),
          adminCard('Payment Control', 'ON', Colors.purple),
        ]),
        SizedBox(height: 20),
        Text('Recent Orders:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: orders.isEmpty? Center(child: Text('Abhi tak koi order nahi')) : ListView.builder(itemCount: orders.length, itemBuilder: (_, i) => Card(child: ListTile(title: Text('Order #${i+1} - ₹${orders[i]['total']}'), subtitle: Text('${orders[i]['items'].length} items - ${orders[i]['date'].substring(0, 16)}'), leading: Icon(Icons.receipt, color: Colors.red))))),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { orders.clear(); allProducts.clear(); allProducts.addAll([{'name': 'T-Shirt', 'price': 399, 'seller': 'Vikky', 'icon': Icons.checkroom}, {'name': 'Shoes', 'price': 999, 'seller': 'Avi', 'icon': Icons.directions_run}]); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sab Reset Ho Gaya!'))); }, child: Text('RESET STORE', style: TextStyle(color: Colors.white)))),
      ])),
    );
  }
  Widget adminCard(String title, String value, Color color) => Expanded(child: Card(color: color, child: Padding(padding: EdgeInsets.all(15), child: Column(children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 12)), SizedBox(height: 5), Text(value, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]))));
}
