// fuel_tracker_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fuel state.dart';


class FuelTrackerCubit extends Cubit<FuelTrackerState> {
  FuelTrackerCubit() : super(FuelTrackerInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addFuelEntry(double liters, double km) async {
    try {
      double avg = (liters / km) * 100;
      await _firestore.collection('fuel_records').add({
        'liters': liters,
        'km': km,
        'avg': avg,
        'timestamp': Timestamp.now(),
      });
      emit(FuelTrackerEntryAdded(avg));
      loadFuelEntries();
    } catch (e) {
      emit(FuelTrackerError('Failed to add entry'));
    }
  }

  void loadFuelEntries() async {
    emit(FuelTrackerLoading());
    try {
      final snapshot = await _firestore
          .collection('fuel_records')
          .orderBy('timestamp', descending: true)
          .get();
      final entries = snapshot.docs
          .map((doc) => FuelEntry(
        liters: doc['liters'],
        km: doc['km'],
        avg: doc['avg'],
      ))
          .toList();
      emit(FuelTrackerLoaded(entries));
    } catch (e) {
      emit(FuelTrackerError('Failed to load entries'));
    }
  }
}

class FuelEntry {
  final double liters;
  final double km;
  final double avg;

  FuelEntry({required this.liters, required this.km, required this.avg});
}