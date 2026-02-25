import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/medicine_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/notification_util.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final Box<Medicine> medicineBox;

  HomeCubit({required this.medicineBox}) : super(HomeInitial());

  void loadMedicines(String profileId, DateTime date, {bool showAll = false}) {
    emit(HomeLoading());
    try {
      final allMedicines = medicineBox.values.toList();
      final List<Medicine> expandedMedicines = [];
      final now = DateTime.now();

      for (var medicine in allMedicines) {
        if (medicine.profileId != profileId) continue;

        if (showAll) {
           final yesterday = now.subtract(const Duration(days: 1));
           final tomorrow = now.add(const Duration(days: 1));
           
           final List<Medicine> candidates = [
             ..._generateForDate(medicine, yesterday),
             ..._generateForDate(medicine, now),
             ..._generateForDate(medicine, tomorrow),
           ];
           
           if (candidates.isNotEmpty) {
               candidates.sort((a, b) => a.startTime.difference(now).abs().compareTo(b.startTime.difference(now).abs()));
               expandedMedicines.add(candidates.first);
           } else {
               expandedMedicines.add(medicine);
           }
        } else {
           expandedMedicines.addAll(_generateForDate(medicine, date));
        }
      }
      
      expandedMedicines.sort((a, b) => a.startTime.compareTo(b.startTime));

      emit(HomeLoaded(
        medicines: expandedMedicines,
        selectedDate: date,
        profileId: profileId,
        isShowingAll: showAll,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  List<Medicine> _generateForDate(Medicine medicine, DateTime date) {
    final List<Medicine> results = [];
    final targetDate = DateTime(date.year, date.month, date.day);

    if (medicine.durationDays != null) {
      final endDate = medicine.startTime.add(Duration(days: medicine.durationDays!));
      final endDay = DateTime(endDate.year, endDate.month, endDate.day);
      if (!targetDate.isBefore(endDay)) return results;
    }

    if (!medicine.isInterval) {
       if (medicine.fixedTime == null) return results;
       
       final startDay = DateTime(medicine.startTime.year, medicine.startTime.month, medicine.startTime.day);
       if (targetDate.isBefore(startDay)) return results;

       bool isTaken = medicine.history.any((dt) => 
         dt.year == targetDate.year && 
         dt.month == targetDate.month && 
         dt.day == targetDate.day
       );
       
       final todayFixedTime = DateTime(
         targetDate.year, targetDate.month, targetDate.day,
         medicine.fixedTime!.hour, medicine.fixedTime!.minute
       );
       
       if (medicine.hideBefore != null && todayFixedTime.isBefore(medicine.hideBefore!)) return results;
       if (medicine.hideAfter != null && todayFixedTime.isAfter(medicine.hideAfter!)) return results;

       bool isDeleted = medicine.deletedOccurrences.any((dt) => 
           dt.year == todayFixedTime.year && 
           dt.month == todayFixedTime.month && 
           dt.day == todayFixedTime.day &&
           dt.hour == todayFixedTime.hour &&
           dt.minute == todayFixedTime.minute
       );
       if (isDeleted) return results;

       results.add(medicine.copyWith(
         startTime: todayFixedTime,
         isTaken: isTaken,
       ));

    } else {
       if (medicine.intervalHours == null) return results;
       
       final start = medicine.startTime;
       if (targetDate.isBefore(DateTime(start.year, start.month, start.day))) return results;

       DateTime currentOccurrence = start;
       
       if (currentOccurrence.isBefore(targetDate)) {
          final diffHours = targetDate.difference(currentOccurrence).inHours;
          int intervals = (diffHours / medicine.intervalHours!).floor();
          currentOccurrence = currentOccurrence.add(Duration(hours: intervals * medicine.intervalHours!));
          
          while (currentOccurrence.isBefore(targetDate)) {
             currentOccurrence = currentOccurrence.add(Duration(hours: medicine.intervalHours!));
          }
       }
       
       final nextDay = targetDate.add(const Duration(days: 1));
       int occurrenceIndex = 0;
       
       final historyToday = medicine.history.where((dt) => 
           dt.year == targetDate.year && 
           dt.month == targetDate.month && 
           dt.day == targetDate.day
       ).toList();
       
       historyToday.sort();
       int takenCount = historyToday.length;

       while (currentOccurrence.isBefore(nextDay)) {
          final lookupTime = currentOccurrence;
          bool isDeleted = medicine.deletedOccurrences.any((dt) => 
              dt.year == lookupTime.year && 
              dt.month == lookupTime.month && 
              dt.day == lookupTime.day &&
              dt.hour == lookupTime.hour &&
              dt.minute == lookupTime.minute
          );
          
          if (!isDeleted) {
            bool isHidden = false;
            if (medicine.hideBefore != null && lookupTime.isBefore(medicine.hideBefore!)) isHidden = true;
            if (medicine.hideAfter != null && lookupTime.isAfter(medicine.hideAfter!)) isHidden = true;

            if (!isHidden) {
              bool isTaken = occurrenceIndex < takenCount;
              
              results.add(medicine.copyWith(
                 startTime: currentOccurrence,
                 isTaken: isTaken,
              ));
            }
          }
          
          currentOccurrence = currentOccurrence.add(Duration(hours: medicine.intervalHours!));
          occurrenceIndex++;
       }
    }
    return results;
  }

  int getUncompletedCountForProfile(String profileId) {
    int count = 0;
    final now = DateTime.now();
    final allMedicines = medicineBox.values.where((m) => m.profileId == profileId).toList();

    for (var medicine in allMedicines) {
      if (medicine.durationDays != null) {
        final endDate = medicine.startTime.add(Duration(days: medicine.durationDays!));
        // We only care about occurrences up to 'now', or 'endDate' if it's already past
        final calcEnd = endDate.isBefore(now) ? endDate : now;
        count += _getUncompletedOccurrencesForMedicine(medicine, calcEnd, now);
      } else {
        count += _getUncompletedOccurrencesForMedicine(medicine, now, now);
      }
    }
    return count;
  }

  int _getUncompletedOccurrencesForMedicine(Medicine medicine, DateTime targetEndTime, DateTime now) {
    int count = 0;
    
    if (!medicine.isInterval) {
      if (medicine.fixedTime == null) return 0;
      
      DateTime current = DateTime(medicine.startTime.year, medicine.startTime.month, medicine.startTime.day);
      final finalEndDay = DateTime(targetEndTime.year, targetEndTime.month, targetEndTime.day);

      while (!current.isAfter(finalEndDay)) {
        final occurrenceTime = DateTime(
          current.year, current.month, current.day,
          medicine.fixedTime!.hour, medicine.fixedTime!.minute
        );

        if (!occurrenceTime.isAfter(targetEndTime)) {
          if (_isOccurrenceValidAndUncompleted(medicine, occurrenceTime, now)) {
            count++;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    } else {
      if (medicine.intervalHours == null) return 0;
      
      DateTime currentOccurrence = medicine.startTime;
      int occurrenceIndex = 0;

      // Optimize: Skip to first valid occurrence if very far in the past? 
      // Actually we need to check history for each to know if it's taken.

      while (!currentOccurrence.isAfter(targetEndTime)) {
        if (_isOccurrenceValidAndUncompletedInterval(medicine, currentOccurrence, occurrenceIndex, now)) {
          count++;
        }
        currentOccurrence = currentOccurrence.add(Duration(hours: medicine.intervalHours!));
        occurrenceIndex++;
      }
    }
    
    return count;
  }

  bool _isOccurrenceValidAndUncompleted(Medicine medicine, DateTime occurrenceTime, DateTime now) {
    if (medicine.hideBefore != null && occurrenceTime.isBefore(medicine.hideBefore!)) return false;
    if (medicine.hideAfter != null && occurrenceTime.isAfter(medicine.hideAfter!)) return false;

    bool isDeleted = medicine.deletedOccurrences.any((dt) => 
        dt.year == occurrenceTime.year && dt.month == occurrenceTime.month && 
        dt.day == occurrenceTime.day && dt.hour == occurrenceTime.hour && dt.minute == occurrenceTime.minute
    );
    if (isDeleted) return false;

    bool isTaken = medicine.history.any((dt) => 
        dt.year == occurrenceTime.year && dt.month == occurrenceTime.month && dt.day == occurrenceTime.day
    );
    
    // We want to count it if it's NOT taken, AND it's either in the past (Missed) or within the last 30 minutes / current (Time to take)
    // Actually, the prompt says "time to take" + "missed". 
    // "Missed" = occurrenceTime + 30 mins is before now.
    // "Time to take" = occurrenceTime is before now, and now is before occurrenceTime + 30 mins.
    // OR we can just say: if occurrenceTime is before `now`, and it's not taken, it's either missed or time to take.
    // WAIT: in MedicineCard, "Time to take" means `!isFuture && !isPassed`. 
    // isFuture = now.isBefore(startTime). 
    // So if now is AFTER or EQUAL to startTime, it's either "Time to take" or "Missed".
    // Therefore, an occurrence is "badge-worthy" if:
    // 1. It is NOT taken.
    // 2. now.isAfter(occurrenceTime) (meaning it's past the exact start time, so it's due now or missed)
    
    if (!isTaken && (now.isAfter(occurrenceTime) || now.isAtSameMomentAs(occurrenceTime))) {
      return true;
    }
    return false;
  }

  bool _isOccurrenceValidAndUncompletedInterval(Medicine medicine, DateTime occurrenceTime, int occurrenceIndex, DateTime now) {
    if (medicine.hideBefore != null && occurrenceTime.isBefore(medicine.hideBefore!)) return false;
    if (medicine.hideAfter != null && occurrenceTime.isAfter(medicine.hideAfter!)) return false;

    bool isDeleted = medicine.deletedOccurrences.any((dt) => 
        dt.year == occurrenceTime.year && dt.month == occurrenceTime.month && 
        dt.day == occurrenceTime.day && dt.hour == occurrenceTime.hour && dt.minute == occurrenceTime.minute
    );
    if (isDeleted) return false;

    final historyOnDay = medicine.history.where((dt) => 
        dt.year == occurrenceTime.year && dt.month == occurrenceTime.month && dt.day == occurrenceTime.day
    ).toList();
    
    // We only care if this specific occurrence index on this day is taken.
    // Wait, interval tracking in UI uses a total count per day.
    // Let's count how many occurrences happen on this specific day up to 'now'.
    // Actually, `occurrenceIndex` is global from startTime. The UI `_generateForDate` resets `occurrenceIndex` to 0 per day, which might be a bug or design choice in `_generateForDate`.
    // Let's look at `_generateForDate` for interval:
    // It does `int occurrenceIndex = 0;` at the start of the day.
    // So if it's the 1st occurrence of the day, it checks if `historyToday.length > 0`.
    
    int indexForToday = _getIndexForToday(medicine, occurrenceTime);
    bool isTaken = indexForToday < historyOnDay.length;

    if (!isTaken && (now.isAfter(occurrenceTime) || now.isAtSameMomentAs(occurrenceTime))) {
      return true;
    }
    return false;
  }

  int _getIndexForToday(Medicine medicine, DateTime occurrenceTime) {
     final targetDate = DateTime(occurrenceTime.year, occurrenceTime.month, occurrenceTime.day);
     DateTime current = medicine.startTime;
     
     if (current.isBefore(targetDate)) {
        final diffHours = targetDate.difference(current).inHours;
        int intervals = (diffHours / medicine.intervalHours!).floor();
        current = current.add(Duration(hours: intervals * medicine.intervalHours!));
        while (current.isBefore(targetDate)) {
           current = current.add(Duration(hours: medicine.intervalHours!));
        }
     }
     
     int idx = 0;
     while (current.isBefore(occurrenceTime)) {
       current = current.add(Duration(hours: medicine.intervalHours!));
       idx++;
     }
     return idx;
  }

  Future<void> markAsTaken(Medicine medicine) async {
    // We don't delete the medicine, just upate history. 
    // The UI will refresh and filter it out.
    // However, if we want to "Delete" it from view, we must ensure loadMedicines is called after.
    // The 'medicine' parameter here is a dynamically generated copy (with specific startTime).
    // We must find the REAL medicine from the Box to save it.
    
    final realMedicine = medicineBox.values.firstWhere((m) => m.id == medicine.id);
    
    // We need to save to Hive, using the specific occurrence time
    realMedicine.history.add(medicine.startTime);
    realMedicine.exactTakenTimes[medicine.startTime.toIso8601String()] = DateTime.now();
    await realMedicine.save();
    
    // Refresh list
    // We need current state to know profile and date
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate, showAll: cur.isShowingAll);
    }
  }

  Future<void> unmarkAsTaken(Medicine medicine) async {
    final realMedicine = medicineBox.values.firstWhere((m) => m.id == medicine.id);
    final targetDate = medicine.startTime;

    if (!realMedicine.isInterval) {
      realMedicine.history.removeWhere((dt) => 
         dt.year == targetDate.year && 
         dt.month == targetDate.month && 
         dt.day == targetDate.day
      );
    } else {
      final historyOnDate = realMedicine.history.where((dt) => 
         dt.year == targetDate.year && 
         dt.month == targetDate.month && 
         dt.day == targetDate.day
      ).toList();
      if (historyOnDate.isNotEmpty) {
        historyOnDate.sort(); // remove the last one added for that day
        realMedicine.history.remove(historyOnDate.last);
      }
    }
    
    realMedicine.exactTakenTimes.remove(medicine.startTime.toIso8601String());
    await realMedicine.save();
    
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate, showAll: cur.isShowingAll);
    }
  }

  Future<void> deleteMedicine(String id) async {
     await medicineBox.delete(id);
     
     final notificationId = NotificationUtil.generateId(id);
     final notificationService = NotificationService();
     for (int i = 0; i < 50; i++) {
        notificationService.cancelNotification(notificationId + i);
     }
     // Refresh
     if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }

  Future<void> deleteMedicines(List<String> rawKeysOrIds) async {
    final Set<String> idsToDelete = {};
    for (var key in rawKeysOrIds) {
      idsToDelete.add(key.split('|')[0]);
    }
    
    for (var medId in idsToDelete) {
      try {
        final realMedicine = medicineBox.values.firstWhere((m) => m.id == medId);
        await realMedicine.delete();

        final notificationId = NotificationUtil.generateId(medId);
        final notificationService = NotificationService();
        for (int i = 0; i < 50; i++) {
           notificationService.cancelNotification(notificationId + i);
        }
      } catch (e) {
        // skip if not found
      }
    }

    // Refresh
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
    }
  }

  Future<void> deleteAllMedicines(String profileId) async {
     final medicinesToDelete = medicineBox.values
        .where((m) => m.profileId == profileId)
        .toList();
     final keysToDelete = medicinesToDelete
        .map((m) => m.key)
        .toList();
     final notificationService = NotificationService();
     for (final medicine in medicinesToDelete) {
         final notificationId = NotificationUtil.generateId(medicine.id);
         for (int i = 0; i < 50; i++) {
             notificationService.cancelNotification(notificationId + i);
         }
     }
     await medicineBox.deleteAll(keysToDelete);
     
     if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      loadMedicines(cur.profileId, cur.selectedDate);
     }
  }

  Future<void> updateMedicineScope(String medicineId, {DateTime? hideBefore, DateTime? hideAfter}) async {
    try {
      final realMedicine = medicineBox.values.firstWhere((m) => m.id == medicineId);
      
      // We apply the bounds if they were passed in
      DateTime? updatedHideBefore = realMedicine.hideBefore;
      if (hideBefore != null) {
         updatedHideBefore = hideBefore;
      }
      
      DateTime? updatedHideAfter = realMedicine.hideAfter;
      if (hideAfter != null) {
         updatedHideAfter = hideAfter;
      }

      await medicineBox.put(realMedicine.key, realMedicine.copyWith(
         hideBefore: updatedHideBefore,
         hideAfter: updatedHideAfter,
      ));

      if (state is HomeLoaded) {
        final cur = state as HomeLoaded;
        loadMedicines(cur.profileId, cur.selectedDate);
      }
    } catch (e) {
      // Not found, ignore
    }
  }
}
