import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fuel state.dart';
import 'fuel-tracker cubit.dart';
import 'model.dart';

class FuelTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocProvider(
        create: (_) => FuelTrackerCubit()..loadFuelEntries(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Fuel Efficiency Tracker'),
            backgroundColor: Colors.teal,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FuelInputSection(),
                SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<FuelTrackerCubit, FuelTrackerState>(
                builder: (context, state) {
                  if (state is FuelTrackerLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is FuelTrackerLoaded) {
                    if (state.entries.isEmpty) {
                      return Center(child: Text('No fuel records available.',
                        style:GoogleFonts.inter(fontSize: 18.sp,fontWeight: FontWeight.bold) ,));
                    } else {
                      return ListView.builder(
                        itemCount: state.entries.length,
                        itemBuilder: (context, index) {
                          final entry = state.entries[index];
                          return FuelRecordCard(
                            entry: entry,
                            onDelete: () {
                              context.read<FuelTrackerCubit>().deleteFuelEntry(entry);
                            },
                          );
                        },
                      );
                    }
                  } else if (state is FuelTrackerError) {
                    return Center(child: Text(state.message));
                  } else {
                    return Center(child: Text('No fuel records available.',
                      style:GoogleFonts.inter(fontSize: 50.sp,fontWeight: FontWeight.bold) ,));
                    }
                  },
                ),
            )],
            ),
          ),
        ),
      ),
    );
  }
}

class FuelInputSection extends StatelessWidget {
  final TextEditingController litersController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController tankcapacityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: litersController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Liters Filled',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
            ),
            prefixIcon: Icon(Icons.local_gas_station),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: kmController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Kilometers Driven',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
            ),
            prefixIcon: Icon(Icons.speed),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: odometerController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Odometer Reading',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
            ),
            prefixIcon: Icon(Icons.av_timer),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: tankcapacityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Tank Capacity',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
            ),
            prefixIcon: Icon(Icons.propane_tank_sharp),
          ),
        ),
        SizedBox(height: 20,),
        ElevatedButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            final liters = double.tryParse(litersController.text);
            final km = double.tryParse(kmController.text);
            final odometer = double.tryParse(odometerController.text);
            final tank = double.tryParse(tankcapacityController.text);
            if (liters != null && tank != null && km != null && odometer != null && km > 0) {
              context.read<FuelTrackerCubit>().addFuelEntry(liters, km, odometer,tank);
              litersController.clear();
              kmController.clear();
              odometerController.clear();
              tankcapacityController.clear();
            }
          },
          child: Text(
            'Calculate Entry',
            style: GoogleFonts.inter(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}

class FuelRecordCard extends StatelessWidget {
  final FuelEntry entry;
  final VoidCallback onDelete;

  FuelRecordCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Liters: ${entry.liters} L', style: TextStyle(fontSize: 16)),
            Text('Kilometers: ${entry.km} km', style: TextStyle(fontSize: 16)),
            Text('odometer: ${entry.odometer} km', style: TextStyle(fontSize: 16)),
            Text('Date: ${entry.date}', style: TextStyle(fontSize: 16)),
            Text(
              'Avg Fuel Consumption: ${entry.avg.toStringAsFixed(2)} L/100km',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
          Text(
            'Estimated Range: ${(entry.tankCapacity / entry.avg * 100).toStringAsFixed(1)} km',
              style: TextStyle(fontSize: 16, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
