import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntryScreen extends StatefulWidget {
  @override
  _FuelEntryScreenState createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();

  double? avgFuelConsumption;

  void _saveData() async {
    final liters = double.tryParse(_litersController.text);
    final km = double.tryParse(_kmController.text);

    if (liters != null && km != null && km > 0) {
      double avg = (liters / km) * 100;

      await FirebaseFirestore.instance.collection('fuel_records').add({
        'liters': liters,
        'km': km,
        'avg': avg,
        'timestamp': Timestamp.now(),
      });

      setState(() {
        avgFuelConsumption = avg;
      });

      _litersController.clear();
      _kmController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fuel Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _litersController,
                decoration: InputDecoration(labelText: 'Liters Filled'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _kmController,
                decoration: InputDecoration(labelText: 'Kilometers Driven'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                child: Text('Save Entry'),
              ),
              if (avgFuelConsumption != null) ...[
                SizedBox(height: 20),
                Text(
                  'Instant Avg: ${avgFuelConsumption!.toStringAsFixed(2)} L/100km',
                  style: TextStyle(fontSize: 18),
                )
              ],
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('fuel_records')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];
                        return ListTile(
                          title: Text(
                              '${data['liters']}L over ${data['km']}km'),
                          subtitle: Text(
                              'Avg: ${data['avg'].toStringAsFixed(2)} L/100km'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
