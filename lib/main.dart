import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// TUMHARI FILES
import 'payment_service.dart';
import 'admin_payment_control.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VAStoreApp());
}

class VAStoreApp extends StatelessWidget {
  const VAStoreApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VA Store', debugShowCheckedModeBanner: false,
      home: const MainController(),
    );
  }
}

// ===== DATA =====
class Product{
  final String id,name,category;
  final double price,oldPrice,rating;
  final int reviews;
  Product({required this.id, required this.name, required this.category, required this.price, required this.oldPrice, required this.rating, required this.reviews});
}
final List<Product> allProducts=[
  Product(id:'1',name:'Men T-Shirt',category:'Kapde',price:499,oldPrice:799,rating:4.5,reviews:120),
  Product(id:'2',name:'Saree',category:'Kapde',price:1299,oldPrice:1999,rating:4.8,reviews:89),
];
List<Product> cartItems=[];

// ===== MAIN CONTROLLER =====
class MainController extends StatefulWidget{const MainController({super.key});@override State<MainController> createState()=>_MainControllerState();}
class _MainControllerState extends State<MainController>{
  int currentIndex=0;
  final pages=const [HomePage(), CartPage(), ProfilePage()];
  @override Widget build(BuildContext context){
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i)=>setState(()=>currentIndex=i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ===== HOME =====
class HomePage extends StatelessWidget{
  const HomePage({super.key});
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('VA Store'), actions: [
        IconButton(icon: Icon(Icons.admin_panel_settings), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>AdminPaymentControl()))),
      ]),
      body: ListView.builder(
        itemCount: allProducts.length,
        itemBuilder: (c,i){
          var p=allProducts[i];
          return ListTile(
            title: Text(p.name), subtitle: Text('Rs ${p.price}'),
            trailing: ElevatedButton(child: Text('Add'), onPressed: (){cartItems.add(p); ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Cart me add hua')));}),
          );
        },
      ),
    );
  }
}

// ===== CART + COD + ONLINE PAY =====
class CartPage extends StatefulWidget{const CartPage({super.key});@override State<CartPage> createState()=>_CartPageState();}
class _CartPageState extends State<CartPage>{
  @override Widget build(BuildContext context){
    double total=cartItems.fold(0,(s,e)=>s+e.price);
    return Scaffold(
      appBar: AppBar(title: Text('Cart - Rs $total')),
      body: Column(children: [
        Expanded(child: ListView(children: cartItems.map((e)=>ListTile(title: Text(e.name), subtitle: Text('Rs ${e.price}'))).toList())),
        Padding(padding: EdgeInsets.all(16), child: Column(children: [
          // ONLINE PAY - Paisa 8955116739 pe
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              String orderId="ORD${DateTime.now().millisecondsSinceEpoch}";
              await PaymentService.payOnline(orderId: orderId, product: "Cart ${cartItems.length} items", amount: total, sellerUpi: "seller@upi");
            },
            child: Text('Online Pay - Rs $total (8955116739 pe jayega)'),
          )),
          SizedBox(height: 10),
          // COD
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              String orderId="ORD${DateTime.now().millisecondsSinceEpoch}";
              await PaymentService.payCOD(orderId: orderId, product: "Cart ${cartItems.length} items", amount: total, sellerUpi: "seller@upi", address: "Customer Address");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('COD Order Place Hua!')));
            },
            child: Text('Cash on Delivery - Rs $total'),
          )),
        ])),
      ]),
    );
  }
}

class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar: AppBar(title: Text('Profile')),body: Center(child: Text('Admin: 8955116739')));}}
class OrderTrackingPage extends StatelessWidget{final double total;const OrderTrackingPage({super.key,required this.total});@override Widget build(BuildContext context){return Scaffold(appBar: AppBar(title: Text('Tracking')),body: Padding(padding: EdgeInsets.all(16),child: Text('Total Rs $total')));}}
