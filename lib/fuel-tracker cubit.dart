// fuel-tracker cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fuel state.dart';
import 'model.dart';

class FuelTrackerCubit extends Cubit<FuelTrackerState> {
  FuelTrackerCubit() : super(FuelTrackerInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addFuelEntry(double liters, double km, double odometer,double tankcapacity) async {
    try {
      double avg = (liters / km) * 100;
      final now = DateTime.now();
      await _firestore.collection('fuel_records').add({
        'liters': liters,
        'km': km,
        'avg': avg,
        'tankcapacity': tankcapacity,
        'odometer': odometer,
        'timestamp': Timestamp.now(),
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      });
      emit(FuelTrackerEntryAdded(avg));
      loadFuelEntries();
    } catch (e) {
      emit(FuelTrackerError('Failed to add entry'));
    }
  }

// Update the loadFuelEntries method in FuelTrackerCubit

  void loadFuelEntries() async {
    emit(FuelTrackerLoading());
    try {
      final snapshot = await _firestore
          .collection('fuel_records')
          .orderBy('timestamp', descending: true)
          .get();

      final entries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FuelEntry(
          id: doc.id,
          liters: (data['liters'] as num? ?? 0).toDouble(),
          km: (data['km'] as num? ?? 0).toDouble(),
          avg: (data['avg'] as num? ?? 0).toDouble(),
          odometer: (data['odometer'] as num? ?? 0).toDouble(),
          date: data['date'] as String? ?? '',
          tankCapacity: (data['tankcapacity'] as num? ?? 0).toDouble(),
        );
      }).toList();

      emit(FuelTrackerLoaded(entries));
    } catch (e, stackTrace) {
      emit(FuelTrackerError('Failed to load entries: $e'));
      print('Error loading entries: $e');
      print('StackTrace: $stackTrace');
    }
  }

  void deleteFuelEntry(FuelEntry entry) async {
    try {
      await _firestore.collection('fuel_records').doc(entry.id).delete();
      emit(FuelTrackerEntryDeleted());
      loadFuelEntries();
    } catch (e) {
      emit(FuelTrackerError('Failed to delete entry'));
    }
  }

}

