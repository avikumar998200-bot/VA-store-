import 'package:flutter/material.dart';

void main() {
  runApp(VAStoreApp());
}

class VAStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VA Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VA Store'), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Welcome to VA Store', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Your Shopping App is Ready!'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
              },
              child: Text('Start Shopping'),
            )
          ],
        ),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final products = [
    {'name': 'T-Shirt', 'price': '₹399', 'icon': Icons.checkroom},
    {'name': 'Shoes', 'price': '₹999', 'icon': Icons.shopping_bag},
    {'name': 'Watch', 'price': '₹1499', 'icon': Icons.watch},
    {'name': 'Headphone', 'price': '₹799', 'icon': Icons.headphones},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products'), backgroundColor: Colors.blue),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(products[index]['icon'] as IconData, size: 60, color: Colors.blue),
                SizedBox(height: 10),
                Text(products[index]['name'] as String, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(products[index]['price'] as String, style: TextStyle(color: Colors.green)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${products[index]['name']} Added to Cart!')),
                    );
                  },
                  child: Text('Add to Cart'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
