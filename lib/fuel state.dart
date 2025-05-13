
import 'model.dart';

abstract class FuelTrackerState {}

class FuelTrackerInitial extends FuelTrackerState {}

class FuelTrackerLoading extends FuelTrackerState {}

class FuelTrackerLoaded extends FuelTrackerState {
  final List<FuelEntry> entries;
  FuelTrackerLoaded(this.entries);
}

class FuelTrackerEntryAdded extends FuelTrackerState {
  final double avg;
  FuelTrackerEntryAdded(this.avg);
}

class FuelTrackerError extends FuelTrackerState {
  final String message;
  FuelTrackerError(this.message);
}

class FuelTrackerEntryDeleted extends FuelTrackerState {}