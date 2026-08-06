import 'package:flutter/material.dart';
void main(){runApp(const VAStoreApp());}

class VAStoreApp extends StatelessWidget{
  const VAStoreApp({super.key});
  @override Widget build(BuildContext context){
    return MaterialApp(
      title:'VA Store',
      debugShowCheckedModeBanner:false,
      theme:ThemeData(primaryColor:const Color(0xFFFF6B00), useMaterial3:true),
      home:const MainController()
    );
  }
}

// Data
class Product{
  final String id,name,category,emoji;
  final double price,oldPrice,rating;
  final int reviews;
  Product({required this.id,required this.name,required this.category,required this.price,required this.oldPrice,required this.rating,required this.reviews,required this.emoji});
}

final List<Product> allProducts=[
  Product(id:'1',name:'Men T-Shirt',category:'Kapde',price:499,oldPrice:799,rating:4.5,reviews:120,emoji:'👕'),
  Product(id:'2',name:'iPhone Cover',category:'Mobile',price:299,oldPrice:499,rating:4.3,reviews:89,emoji:'📱'),
  Product(id:'3',name:'Running Shoes',category:'Shoes',price:1999,oldPrice:2999,rating:4.7,reviews:250,emoji:'👟'),
  Product(id:'4',name:'Women Kurti',category:'Kapde',price:899,oldPrice:1299,rating:4.4,reviews:95,emoji:'👗'),
  Product(id:'5',name:'Earbuds',category:'Mobile',price:1499,oldPrice:2499,rating:4.6,reviews:310,emoji:'🎧'),
  Product(id:'6',name:'Formal Shoes',category:'Shoes',price:2499,oldPrice:3999,rating:4.2,reviews:67,emoji:'👞'),
  Product(id:'7',name:'Jeans',category:'Kapde',price:1199,oldPrice:1999,rating:4.5,reviews:140,emoji:'👖'),
  Product(id:'8',name:'Smart Watch',category:'Mobile',price:2999,oldPrice:4999,rating:4.8,reviews:420,emoji:'⌚'),
];

List<Product> cartItems=[], wishlistItems=[];
String selectedCategory='All', searchQuery='';

// Main Controller with Bottom Nav
class MainController extends StatefulWidget{const MainController({super.key});@override State<MainController> createState()=>_MainControllerState();}
class _MainControllerState extends State<MainController>{
  int currentIndex=0;
  final pages=[const HomePage(), const WishlistPage(), const CartPage(), const AdminSuperDashboard(), const ProfilePage()];
  @override Widget build(BuildContext context){
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected:(i)=>setState(()=>currentIndex=i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Wishlist'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ]
      )
    );
  }
}

// Home Page
class HomePage extends StatefulWidget{const HomePage({super.key});@override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
  @override Widget build(BuildContext context){
    List<Product> filtered = allProducts.where((p){
      bool cat = selectedCategory=='All' || p.category==selectedCategory;
      bool search = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return cat && search;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('VA Store - Tu Hi Boss'), backgroundColor: const Color(0xFFFF6B00), foregroundColor: Colors.white),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=>setState(()=>searchQuery=v), decoration: InputDecoration(hintText: '🔍 Search kapde, mobile, shoes...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal:12), children: ['All','Kapde','Mobile','Shoes'].map((cat)=> Padding(padding: const EdgeInsets.only(right:8), child: ChoiceChip(label: Text(cat), selected: selectedCategory==cat, onSelected: (_)=>setState(()=>selectedCategory=cat)))).toList())),
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.68, crossAxisSpacing:12, mainAxisSpacing:12), itemCount: filtered.length, itemBuilder: (c,i){
          final p=filtered[i]; bool isWish=wishlistItems.contains(p);
          return InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetailPage(product:p))), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius:4)]), child: Column(children: [
            Expanded(child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))), child: Center(child: Text(p.emoji, style: const TextStyle(fontSize:50))))),
            Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines:1),
              Row(children: [const Icon(Icons.star,size:14,color:Colors.orange), Text(' ${p.rating} (${p.reviews})', style: const TextStyle(fontSize:12))]),
              Row(children: [Text('₹${p.price.toInt()}', style: const TextStyle(fontWeight:FontWeight.bold, color:Color(0xFFFF6B00))), const SizedBox(width:5), Text('₹${p.oldPrice.toInt()}', style: const TextStyle(decoration:TextDecoration.lineThrough, fontSize:11, color:Colors.grey))]),
              Row(children: [Expanded(child: ElevatedButton(onPressed: ()=>setState(()=>{if(!cartItems.contains(p)) cartItems.add(p)}), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: EdgeInsets.zero), child: const Text('Add', style: TextStyle(color:Colors.white, fontSize:12)))), IconButton(onPressed: ()=>setState(()=>{isWish? wishlistItems.remove(p) : wishlistItems.add(p)}), icon: Icon(isWish? Icons.favorite: Icons.favorite_border, color: isWish? Colors.red: Colors.grey, size:20))])
            ]))
          ])));
        }))
      ])
    );
  }
}

// Product Detail + UPI/Card/COD + Reviews + Tracking
class ProductDetailPage extends StatefulWidget{final Product product; const ProductDetailPage({super.key, required this.product}); @override State<ProductDetailPage> createState()=>_ProductDetailPageState();}
class _ProductDetailPageState extends State<ProductDetailPage>{
  String pay='COD';
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Text(widget.product.emoji, style: const TextStyle(fontSize:100))),
        Text(widget.product.name, style: const TextStyle(fontSize:22, fontWeight:FontWeight.bold)),
        Row(children: [const Icon(Icons.star,color:Colors.orange), Text(' ${widget.product.rating} | ${widget.product.reviews} Reviews')]),
        const SizedBox(height:8),
        Row(children: [Text('₹${widget.product.price.toInt()}', style: const TextStyle(fontSize:24, fontWeight:FontWeight.bold, color:Color(0xFFFF6B00))), const SizedBox(width:10), Text('₹${widget.product.oldPrice.toInt()}', style: const TextStyle(decoration:TextDecoration.lineThrough, color:Colors.grey))]),
        const SizedBox(height:16),
        const Text('💳 Payment Select Karo:', style: TextStyle(fontWeight:FontWeight.bold)),
        RadioListTile(value:'UPI', groupValue:pay, onChanged:(v)=>setState(()=>pay=v!), title: const Text('UPI')),
        RadioListTile(value:'Card', groupValue:pay, onChanged:(v)=>setState(()=>pay=v!), title: const Text('Card')),
        RadioListTile(value:'COD', groupValue:pay, onChanged:(v)=>setState(()=>pay=v!), title: const Text('COD - Cash on Delivery')),
        const SizedBox(height:16),
        const Text('⭐ Reviews:', style: TextStyle(fontWeight:FontWeight.bold)),
        const ListTile(leading: CircleAvatar(child: Text('R')), title: Text('Rahul ★★★★★'), subtitle: Text('Quality bahut achi hai!')),
        const ListTile(leading: CircleAvatar(child: Text('A')), title: Text('Anjali ★★★★☆'), subtitle: Text('Price ke hisab se best hai')),
        const SizedBox(height:16),
        const Text('📦 Tracking:', style: TextStyle(fontWeight:FontWeight.bold)),
        const LinearProgressIndicator(value:0.6, color:Color(0xFFFF6B00)),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Ordered'), Text('Shipped'), Text('Delivered')])
      ])),
      bottomNavigationBar: Padding(padding: const EdgeInsets.all(12), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: const EdgeInsets.all(16)), onPressed: (){ if(!cartItems.contains(widget.product)) cartItems.add(widget.product); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.product.name} added with $pay'))); }, child: Text('Buy Now - ₹${widget.product.price.toInt()} ($pay)', style: const TextStyle(color:Colors.white))))
    );
  }
}

class WishlistPage extends StatefulWidget{const WishlistPage({super.key});@override State<WishlistPage> createState()=>_WishlistPageState();}
class _WishlistPageState extends State<WishlistPage>{@override Widget build(BuildContext context){return Scaffold(appBar: AppBar(title: const Text('❤️ Wishlist')), body: wishlistItems.isEmpty? const Center(child: Text('Khali hai')) : ListView.builder(itemCount: wishlistItems.length, itemBuilder: (c,i)=> ListTile(title: Text(wishlistItems[i].name), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=>setState(()=>wishlistItems.removeAt(i))))));}}

class CartPage extends StatefulWidget{const CartPage({super.key});@override State<CartPage> createState()=>_CartPageState();}
class _CartPageState extends State<CartPage>{@override Widget build(BuildContext context){double total = cartItems.fold(0, (sum,item)=> sum + item.price); return Scaffold(appBar: AppBar(title: const Text('🛒 Cart')), body: Column(children: [Expanded(child: cartItems.isEmpty? const Center(child: Text('Cart khali')) : ListView.builder(itemCount: cartItems.length, itemBuilder: (c,i)=> ListTile(leading: Text(cartItems[i].emoji, style: const TextStyle(fontSize:30)), title: Text(cartItems[i].name), subtitle: Text('₹${cartItems[i].price.toInt()}'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=>setState(()=>cartItems.removeAt(i)))))), Container(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontSize:18, fontWeight:FontWeight.bold)), Text('₹${total.toInt()}', style: const TextStyle(fontSize:18, fontWeight:FontWeight.bold, color:Color(0xFFFF6B00)))]), const SizedBox(height:10), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: const EdgeInsets.all(14)), onPressed: total==0? null : ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>OrderTrackingPage(total:total))), child: const Text('💳 Checkout', style: TextStyle(color:Colors.white))))]))]));}}

class OrderTrackingPage extends StatelessWidget{final double total; const OrderTrackingPage({super.key, required this.total}); @override Widget build(BuildContext context){return Scaffold(appBar: AppBar(title: const Text('📦 Tracking')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Icon(Icons.check_circle,size:80,color:Colors.green), Text('Order ₹${total.toInt()} Placed!', style: const TextStyle(fontSize:22, fontWeight:FontWeight.bold)), const Stepper(currentStep:1, controlsBuilder: (c,d)=> const SizedBox(), steps: [Step(title: Text('Ordered'), content: Text('Paid'), isActive:true), Step(title: Text('Shipped'), content: Text('Courier'), isActive:true), Step(title: Text('Delivered'), content: Text('Ghar pe'), isActive:false)])])));}}

class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar: AppBar(title: const Text('👤 Profile')), body: ListView(children: [const SizedBox(height:20), const CircleAvatar(radius:40, child: Icon(Icons.person,size:50)), const Center(child: Text('Vikky - Super Admin', style: TextStyle(fontSize:20, fontWeight:FontWeight.bold))), const Center(child: Text('Tu hi Admin + Super Admin hai')), const Divider(), ListTile(leading: const Icon(Icons.admin_panel_settings), title: const Text('Admin Panel Kholo'), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const AdminSuperDashboard())))]));}}

// ADMIN + SUPER ADMIN - SELL & SELLER Control (Tu Hi Boss)
class AdminSuperDashboard extends StatefulWidget{const AdminSuperDashboard({super.key});@override State<AdminSuperDashboard> createState()=>_AdminSuperDashboardState();}
class _AdminSuperDashboardState extends State<AdminSuperDashboard>{
  int tab=0;
  List<Map> sellers=[{"name":"Ramesh Kirana","status":"Active","sales":"₹45,000"}, {"name":"Amit Shoes","status":"Pending","sales":"₹12,000"}, {"name":"Fashion Hub","status":"Active","sales":"₹78,000"}];
  List<Map> products=[{"name":"T-Shirt","stock":50,"price":499}, {"name":"Shoes","stock":20,"price":1999}];
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('👑 SELL & SELLER Control'), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: Column(children: [
        Container(color: Colors.red.shade50, padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('₹1.2L','Sale'), _stat('3','Sellers'), _stat('145','Users'), _stat('8','Products')])),
        TabBar(onTap: (i)=>setState(()=>tab=i), labelColor: Colors.red, tabs: const [Tab(text:'SELL'), Tab(text:'SELLER'), Tab(text:'Orders')],),
        Expanded(child: tab==0? _sellControl() : tab==1? _sellerControl() : _ordersControl())
      ]),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.red, onPressed: ()=>_addDialog(), child: const Icon(Icons.add, color: Colors.white))
    );
  }
  Widget _stat(String v,String l)=> Column(children: [Text(v, style: const TextStyle(fontWeight:FontWeight.bold, fontSize:18)), Text(l, style: const TextStyle(fontSize:11))]);
  Widget _sellControl(){return ListView.builder(itemCount: products.length, itemBuilder: (c,i){var p=products[i]; return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(p['name']), subtitle: Text('Stock:${p['stock']} | ₹${p['price']}'), trailing: IconButton(icon: const Icon(Icons.delete, color:Colors.red), onPressed: ()=>setState(()=>products.removeAt(i)))));});}
  Widget _sellerControl(){return ListView.builder(itemCount: sellers.length, itemBuilder: (c,i){var s=sellers[i]; return Card(margin: const EdgeInsets.all(8), child: ListTile(leading: CircleAvatar(child: Text(s['name'][0])), title: Text(s['name']), subtitle: Text('${s['sales']} | ${s['status']}'), trailing: PopupMenuButton(onSelected: (v){if(v=='delete') setState(()=>sellers.removeAt(i)); if(v=='approve') setState(()=>sellers[i]['status']='Active'); if(v=='block') setState(()=>sellers[i]['status']='Blocked');}, itemBuilder: (_)=>[const PopupMenuItem(value:'approve', child: Text('✅ Approve')), const PopupMenuItem(value:'block', child: Text('🚫 Block')), const PopupMenuItem(value:'delete', child: Text('❌ Delete'))])));});}
  Widget _ordersControl(){return ListView(children: const [ListTile(title: Text('Order #1234'), subtitle: Text('Vikky | ₹499 | COD'), trailing: Chip(label: Text('Pending'))), ListTile(title: Text('Order #1235'), subtitle: Text('Amit | ₹1999 | UPI'), trailing: Chip(label: Text('Shipped')))]);}
  void _addDialog(){showDialog(context: context, builder: (_)=> AlertDialog(title: const Text('Add Product'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText:'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))]), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: (){Navigator.pop(context); setState(()=>products.add({"name":"New Product","stock":10,"price":999}));}, child: const Text('Add'))]));}
}