import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPaymentControl extends StatefulWidget {
  @override _AdminPaymentControlState createState() => _AdminPaymentControlState();
}

class _AdminPaymentControlState extends State<AdminPaymentControl> {
  bool isAuto = false;
  TextEditingController manualAmountCtrl = TextEditingController();
  TextEditingController commissionCtrl = TextEditingController(text: "10");
  TextEditingController upiIdCtrl = TextEditingController();
  TextEditingController phonePeCtrl = TextEditingController();
  TextEditingController accountNameCtrl = TextEditingController();
  TextEditingController accountNumberCtrl = TextEditingController();
  TextEditingController ifscCtrl = TextEditingController();

  String currentUpi = "8955116739@upi";
  String currentPhonePe = "8955116739";

  @override
  void initState(){
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    var doc = await FirebaseFirestore.instance.collection('admin_settings').doc('payment').get();
    if(doc.exists){
      setState(() {
        currentUpi = doc['upi_id'] ?? "8955116739@upi";
        currentPhonePe = doc['phonepe_number'] ?? "8955116739";
        upiIdCtrl.text = currentUpi;
        phonePeCtrl.text = currentPhonePe;
        accountNameCtrl.text = doc['account_name'] ?? "Vikky Meghwal";
        accountNumberCtrl.text = doc['account_number'] ?? "";
        ifscCtrl.text = doc['ifsc'] ?? "";
        isAuto = doc['payout_mode'] == 'auto';
        commissionCtrl.text = (doc['commission'] ?? 10).toString();
      });
    } else {
      upiIdCtrl.text = currentUpi;
      phonePeCtrl.text = currentPhonePe;
    }
  }

  _savePaymentSettings() async {
    await FirebaseFirestore.instance.collection('admin_settings').doc('payment').set({
      'upi_id': upiIdCtrl.text.trim(),
      'phonepe_number': phonePeCtrl.text.trim(),
      'account_name': accountNameCtrl.text.trim(),
      'account_number': accountNumberCtrl.text.trim(),
      'ifsc': ifscCtrl.text.trim(),
      'payout_mode': isAuto ? 'auto' : 'manual',
      'commission': double.tryParse(commissionCtrl.text) ?? 10,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      currentUpi = upiIdCtrl.text.trim();
      currentPhonePe = phonePeCtrl.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Payment Settings Save Ho Gaya!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Payment Control'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Info Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Active:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('📱 PhonePe: $currentPhonePe'),
                    Text('💳 UPI: $currentUpi'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text('1. Online Payment Settings (Tumhara Paisa Yaha Ayega)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            TextField(controller: phonePeCtrl, decoration: InputDecoration(labelText: 'PhonePe Number (8955116739)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
            SizedBox(height: 10),
            TextField(controller: upiIdCtrl, decoration: InputDecoration(labelText: 'UPI ID (8955116739@upi / ybl)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payment))),
            SizedBox(height: 10),
            TextField(controller: accountNameCtrl, decoration: InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder())),
            SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: accountNumberCtrl, decoration: InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: ifscCtrl, decoration: InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()))),
            ]),
            SizedBox(height: 20),

            Text('2. Seller Payout Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SwitchListTile(
              title: Text(isAuto ? 'AUTO: Commission kaat ke jayega' : 'MANUAL: Jitna bhejoge utna jayega'),
              value: isAuto,
              onChanged: (v)=>setState(()=>isAuto=v),
            ),
            TextField(controller: manualAmountCtrl, decoration: InputDecoration(labelText: 'Manual Amount (Kitna bhejna hai)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            SizedBox(height: 10),
            TextField(controller: commissionCtrl, decoration: InputDecoration(labelText: 'Auto Commission % (Ex: 10)', border: OutlineInputBorder()), keyboardType: TextInputType.number),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: _savePaymentSettings,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text('SAVE ALL SETTINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),

            // Test Buttons
            Text('3. Test Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () async {
                String upi = "upi://pay?pa=${upiIdCtrl.text}&pn=VAStore&am=1&cu=INR";
                await launchUrl(Uri.parse(upi));
              }, child: Text('Test UPI'))),
              SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () async {
                String upi = "phonepe://pay?pa=${upiIdCtrl.text}&pn=VAStore&am=1&cu=INR";
                await launchUrl(Uri.parse(upi));
              }, child: Text('Test PhonePe'))),
            ]),
          ],
        ),
      ),
    );
  }
}
