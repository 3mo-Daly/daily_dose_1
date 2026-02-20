import 'dart:io';

void main() {
  final file = File('lib/features/home/cubit/home_cubit.dart');
  String content = file.readAsStringSync();
  
  // Find start of loadMedicines
  int startIdx = content.indexOf('  void loadMedicines(String profileId, DateTime date, {bool showAll = false}) {');
  
  // Find end of loadMedicines
  int endIdx = content.indexOf('  Future<void> markAsTaken(Medicine medicine) async {');
  
  if (startIdx == -1 || endIdx == -1) {
     print('Could not find indices');
     return;
  }
  
  String newLoadMedicines = '''
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

''';

  content = content.replaceRange(startIdx, endIdx, newLoadMedicines);
  file.writeAsStringSync(content);
  print('Successfully refactored home_cubit.dart');
}
