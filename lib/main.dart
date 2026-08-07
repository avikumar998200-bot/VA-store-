Control'), backgroundColor: Colors.red, foregroundColor: Colors.white),
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
