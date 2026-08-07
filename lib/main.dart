import 'package:flutter/material.dart';
void main(){runApp(const VAStoreApp());}
class VAStoreApp extends StatelessWidget{
const VAStoreApp({super.key});
@override Widget build(BuildContext context){
return MaterialApp(title:'VA Store',debugShowCheckedModeBanner:false,home:const MainController());
}}
class Product{final String id,name,category;final double price,oldPrice,rating;final int reviews;Product({required this.id,required this.name,required this.category,required this.price,required this.oldPrice,required this.rating,required this.reviews});}
final List<Product> allProducts=[Product(id:'1',name:'Men T-Shirt',category:'Kapde',price:499,oldPrice:799,rating:4.5,reviews:120),Product(id:'2',name:'iPhone Cover',category:'Mobile',price:299,oldPrice:499,rating:4.3,reviews:89),Product(id:'3',name:'Running Shoes',category:'Shoes',price:1999,oldPrice:2999,rating:4.7,reviews:250),Product(id:'4',name:'Women Kurti',category:'Kapde',price:899,oldPrice:1299,rating:4.4,reviews:95),];
List<Product> cartItems=[];String selectedCategory='All';
class MainController extends StatefulWidget{const MainController({super.key});@override State<MainController> createState()=>_MainControllerState();}
class _MainControllerState extends State<MainController>{
int currentIndex=0;final pages=const[HomePage(),CartPage(),ProfilePage()];
@override Widget build(BuildContext context){
return Scaffold(body:pages[currentIndex],bottomNavigationBar:NavigationBar(selectedIndex:currentIndex,onDestinationSelected:(i)=>setState(()=>currentIndex=i),destinations:const[NavigationDestination(icon:Icon(Icons.home),label:'Home'),NavigationDestination(icon:Icon(Icons.shopping_cart),label:'Cart'),NavigationDestination(icon:Icon(Icons.person),label:'Profile')]));
}}
class HomePage extends StatelessWidget{const HomePage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:Text('VA Store'),backgroundColor:Color(0xFFFF6B00),foregroundColor:Colors.white),body:ListView.builder(itemCount:allProducts.length,itemBuilder:(c,i){var p=allProducts[i];return Card(margin:EdgeInsets.all(8),child:ListTile(title:Text(p.name,style:TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('₹${p.price.toInt()}'),trailing:IconButton(icon:Icon(Icons.add_shopping_cart,color:Color(0xFFFF6B00)),onPressed:(){cartItems.add(p);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${p.name} Added')));} ),));}));}}
class CartPage extends StatefulWidget{const CartPage({super.key});@override State<CartPage> createState()=>_CartPageState();}
class _CartPageState extends State<CartPage>{@override Widget build(BuildContext context){double total=cartItems.fold(0,(sum,p)=>sum+p.price);return Scaffold(appBar:AppBar(title:Text('Cart')),body:Column(children:[Expanded(child:cartItems.isEmpty?Center(child:Text('Cart Empty')):ListView.builder(itemCount:cartItems.length,itemBuilder:(c,i)=>ListTile(title:Text(cartItems[i].name),trailing:IconButton(icon:Icon(Icons.delete),onPressed:()=>setState(()=>cartItems.removeAt(i)))))),Padding(padding:EdgeInsets.all(16),child:Column(children:[Text('Total: ₹${total.toInt()}',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),SizedBox(height:10),SizedBox(width:double.infinity,child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFFFF6B00),foregroundColor:Colors.white),onPressed:total==0?null:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OrderTrackingPage(total:total))),child:Text('Checkout')))]))]));
}}
class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:Text('Profile')),body:Center(child:Text('Vikky Meghwal\nVA Store Owner',textAlign:TextAlign.center)));}
}
class OrderTrackingPage extends StatelessWidget{
final double total;const OrderTrackingPage({super.key,required this.total});
@override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:Text('Tracking')),body:Padding(padding:EdgeInsets.all(20),child:Column(children:[Icon(Icons.check_circle,size:80,color:Colors.green),SizedBox(height:16),Text('Order ₹${total.toInt()} Placed!',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),SizedBox(height:20),Stepper(currentStep:1,controlsBuilder:(c,d)=>SizedBox(),steps:[Step(title:Text('Ordered'),content:Text('Paid'),isActive:true),Step(title:Text('Shipped'),content:Text('Courier'),isActive:true),Step(title:Text('Delivered'),content:Text('Ghar pe'),isActive:false)])])));
}
}
