import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPaymentControl extends StatefulWidget {
  @override _State createState() => _State();
}

class _State extends State<AdminPaymentControl> {
  String payoutMode = "manual";
  double commission = 10;

  @override
  void initState(){
    super.initState();
    FirebaseFirestore.instance.collection('admin_settings').doc('payment').snapshots().listen((doc){
      if(doc.exists) setState((){
        payoutMode = doc['payout_mode']?? 'manual';
        commission = (doc['commission']?? 10).toDouble();
      });
    });
  }

  @override Widget build(BuildContext c){
    bool isAuto = payoutMode == "automatic";
    return Scaffold(
      appBar: AppBar(title: Text("Admin - 8955116739")),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(isAuto? "AUTO: Fixed Commission" : "MANUAL: Jitna bhejoge utna"),
            value: isAuto,
            onChanged: (v){
              FirebaseFirestore.instance.collection('admin_settings').doc('payment').set({'payout_mode': v? 'automatic' : 'manual'}, SetOptions(merge: true));
            },
          ),
          if(isAuto) Slider(value: commission, min: 5, max: 50, divisions: 9, label: "${commission.toInt()}%", onChanged: (v){
            setState(()=>commission=v);
            FirebaseFirestore.instance.collection('admin_settings').doc('payment').set({'commission': v}, SetOptions(merge: true));
          }),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (c,snap){
                if(!snap.hasData) return CircularProgressIndicator();
                return ListView(
                  children: snap.data!.docs.map((o){
                    double total = (o['amount']??0).toDouble();
                    double autoAmt = total - (total * commission / 100);
                    var ctrl = TextEditingController(text: autoAmt.toStringAsFixed(0));
                    bool isCOD = o['payment_method']=='cod';
                    return Card(
                      color: isCOD? Colors.orange[50] : Colors.green[50],
                      child: ListTile(
                        title: Text("${o['productName']} - Rs $total ${isCOD? '(COD)': '(Online)'}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Seller: ${o['sellerUpi']}"),
                            if(!isCOD && !isAuto) TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Kitna bhejna hai?")),
                          ],
                        ),
                        trailing: isCOD? Text("COD\nOrder") : ElevatedButton(
                          child: Text(isAuto? "Auto Rs $autoAmt" : "Bhejo"),
                          onPressed: () async {
                            double send = isAuto? autoAmt : double.tryParse(ctrl.text)??0;
                            String url = "upi://pay?pa=${o['sellerUpi']}&am=$send&pn=Seller&cu=INR";
                            await launchUrl(Uri.parse(url));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
