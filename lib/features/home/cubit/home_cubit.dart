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

  Future<void> markAsTaken(Medicine medicine) async {
    // We don't delete the medicine, just upate history. 
    // The UI will refresh and filter it out.
    // However, if we want to "Delete" it from view, we must ensure loadMedicines is called after.
    // The 'medicine' parameter here is a dynamically generated copy (with specific startTime).
    // We must find the REAL medicine from the Box to save it.
    
    final realMedicine = medicineBox.values.firstWhere((m) => m.id == medicine.id);
    
    // We need to save to Hive, using the specific occurrence time
    realMedicine.history.add(medicine.startTime);
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
