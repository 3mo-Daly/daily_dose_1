import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/medicine_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final Box<Medicine> medicineBox;

  HomeCubit({required this.medicineBox}) : super(HomeInitial());

  void loadMedicines(String profileId, DateTime date) {
    emit(HomeLoading());
    try {
      final allMedicines = medicineBox.values.toList();
      final List<Medicine> expandedMedicines = [];

      for (var medicine in allMedicines) {
        if (medicine.profileId != profileId) continue;

        final targetDate = DateTime(date.year, date.month, date.day);

        // Check duration expiration
        if (medicine.durationDays != null) {
          final endDate = medicine.startTime.add(Duration(days: medicine.durationDays!));
          // If the END of the target date is after the end date?
          // Let's keep it simple: if targetDate (00:00) is after endDateday (00:00), hide.
          final endDay = DateTime(endDate.year, endDate.month, endDate.day);
           
          // If duration is 1 day, startTime is today. EndDate is tomorrow same time.
          // endDay is tomorrow. targetDate is today. today is before tomorrow. Show.
          // If targetDate is tomorrow. tomorrow is NOT before tomorrow (it is equal).
          // user said "leave empty for just today". So if duration=1, it shows on day 1, hides on day 2.
          // so if targetDate >= endDay, hide.
           
          if (!targetDate.isBefore(endDay)) continue;
        }

        // Logic to determine if medicine is scheduled for this day
        // And generate occurrences.
        
        if (!medicine.isInterval) {
           // Fixed Time (Once per day)
           if (medicine.fixedTime == null) continue;
           
           // Check start date (can't show before start date)
           final startDay = DateTime(medicine.startTime.year, medicine.startTime.month, medicine.startTime.day);
           if (targetDate.isBefore(startDay)) continue;

           // It is a fixed daily medicine.
           // Check if taken today.
           bool isTaken = medicine.history.any((dt) => 
             dt.year == targetDate.year && 
             dt.month == targetDate.month && 
             dt.day == targetDate.day
           );
           
           // Create a copy with the specific time for today
           final todayFixedTime = DateTime(
             targetDate.year, targetDate.month, targetDate.day,
             medicine.fixedTime!.hour, medicine.fixedTime!.minute
           );
           
           // Skip if this occurrence was explicitly deleted
           bool isDeleted = medicine.deletedOccurrences.any((dt) => 
               dt.year == todayFixedTime.year && 
               dt.month == todayFixedTime.month && 
               dt.day == todayFixedTime.day &&
               dt.hour == todayFixedTime.hour &&
               dt.minute == todayFixedTime.minute
           );
           if (isDeleted) continue;

           expandedMedicines.add(medicine.copyWith(
             startTime: todayFixedTime,
             isTaken: isTaken,
           ));

        } else {
           // Interval Medicine (Multiple times per day)
           if (medicine.intervalHours == null) continue;
           
           // 1. Determine the first occurrence ON or AFTER the target date's start (00:00).
           // The medicine started at `medicine.startTime`.
           // We need to find `k` such that `startTime + k * interval` falls within `targetDate`.
           
           final start = medicine.startTime;
           
           // If targetDate is before the medicine start date, skip entirely.
           if (targetDate.isBefore(DateTime(start.year, start.month, start.day))) continue;

           // Find the first occurrence for this day.
           // diff = targetDate (00:00) - start
           // We want to find the first time >= targetDate 00:00.
           // However, if `start` is later than 00:00 today (e.g. today at 10am), then start IS the first occurrence.
           
           DateTime currentOccurrence = start;
           
           // Fast forward to today
           if (currentOccurrence.isBefore(targetDate)) {
              final diffHours = targetDate.difference(currentOccurrence).inHours;
              // Add intervals until we account for the diff
              // (diffHours / intervalHours).ceil() * intervalHours ?
              // safer to just loop or use math.
              int intervals = (diffHours / medicine.intervalHours!).floor();
              currentOccurrence = currentOccurrence.add(Duration(hours: intervals * medicine.intervalHours!));
              
              // Ensure we are inside today or past it.
              // If still before today (due to floor), add one more.
              while (currentOccurrence.isBefore(targetDate)) {
                 currentOccurrence = currentOccurrence.add(Duration(hours: medicine.intervalHours!));
              }
           }
           
           // Now `currentOccurrence` is the first occurrence >= 00:00 today.
           // Collect all occurrences that fall within "today" (before tomorrow 00:00).
           
           final nextDay = targetDate.add(const Duration(days: 1));
           
           int occurrenceIndex = 0;
           // We also need to know how many times it was taken TODAY to mark the correct ones as taken.
           // Count history entries for today.
           final historyToday = medicine.history.where((dt) => 
               dt.year == targetDate.year && 
               dt.month == targetDate.month && 
               dt.day == targetDate.day
           ).toList();
           
           // Sort history just in case
           historyToday.sort();
           int takenCount = historyToday.length;

           while (currentOccurrence.isBefore(nextDay)) {
              // Check if occurrence was explicitly deleted
              final lookupTime = currentOccurrence;
              bool isDeleted = medicine.deletedOccurrences.any((dt) => 
                  dt.year == lookupTime.year && 
                  dt.month == lookupTime.month && 
                  dt.day == lookupTime.day &&
                  dt.hour == lookupTime.hour &&
                  dt.minute == lookupTime.minute
              );
              
              if (!isDeleted) {
                // Add this occurrence
                // Check if this specific index is taken
                bool isTaken = occurrenceIndex < takenCount;
                
                expandedMedicines.add(medicine.copyWith(
                   startTime: currentOccurrence,
                   isTaken: isTaken,
                ));
              }
              
              currentOccurrence = currentOccurrence.add(Duration(hours: medicine.intervalHours!));
              occurrenceIndex++;
           }
        }
      }
      
      // Sort by time
      expandedMedicines.sort((a, b) => a.startTime.compareTo(b.startTime));

      emit(HomeLoaded(
        medicines: expandedMedicines,
        selectedDate: date,
        profileId: profileId,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> markAsTaken(Medicine medicine) async {
    // We don't delete the medicine, just upate history. 
    // The UI will refresh and filter it out.
    // However, if we want to "Delete" it from view, we must ensure loadMedicines is called after.
    // The 'medicine' parameter here is a dynamically generated copy (with specific startTime).
    // We must find the REAL medicine from the Box to save it.
    
    final realMedicine = medicineBox.values.firstWhere((m) => m.id == medicine.id);
    
    // We need to save to Hive.
    realMedicine.history.add(DateTime.now());
    await realMedicine.save();
    
    // Refresh list
    // We need current state to know profile and date
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }

  Future<void> deleteMedicine(String id) async {
     await medicineBox.delete(id);
     // Refresh
     if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }

  Future<void> deleteMedicines(List<String> rawKeysOrIds) async {
    // The keys from the multi-select UI are now composite: "medicineId|ISO8601String"
    // To support backward compatibility if it's just an "id", we parse safely.
    for (var key in rawKeysOrIds) {
      final parts = key.split('|');
      final medId = parts[0];

      try {
        final realMedicine = medicineBox.values.firstWhere((m) => m.id == medId);

        if (parts.length > 1) {
          // It's a specific occurrence deletion
          final specificTime = DateTime.parse(parts[1]);
          realMedicine.deletedOccurrences.add(specificTime);
          await realMedicine.save();
        } else {
           // It's a full deletion 
           await realMedicine.delete();
        }
      } catch (e) {
        // Medicine not found, skip
      }
    }

    // Refresh
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }

  Future<void> deleteAllMedicines(String profileId) async {
     final keysToDelete = medicineBox.values
        .where((m) => m.profileId == profileId)
        .map((m) => m.key)
        .toList();
     
     await medicineBox.deleteAll(keysToDelete);
     
     if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }
}
