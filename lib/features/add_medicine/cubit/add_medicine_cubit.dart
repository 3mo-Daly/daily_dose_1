import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../models/medicine_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/notification_util.dart';
import 'add_medicine_state.dart';

class AddMedicineCubit extends Cubit<AddMedicineState> {
  final Box<Medicine> medicineBox;
  final NotificationService notificationService;

  AddMedicineCubit({
    required this.medicineBox,
    required this.notificationService,
  }) : super(AddMedicineInitial());

  Future<void> addMedicine({
    required String profileId,
    required String profileName,
    required String name,
    required String dosage,
    String? imagePath,
    required bool isInterval,
    required DateTime startTime,
    int? intervalHours,
    DateTime? fixedTime,
    int? durationDays,
  }) async {
    emit(AddMedicineLoading());
    try {
      final effectiveDuration = durationDays ?? 1; // Default to 1 day if not specified

      final id = const Uuid().v4();
      final medicine = Medicine(
        id: id,
        profileId: profileId,
        name: name,
        dosage: dosage,
        imagePath: imagePath,
        isInterval: isInterval,
        startTime: startTime,
        intervalHours: intervalHours,
        fixedTime: fixedTime,
        durationDays: effectiveDuration,
      );

      await medicineBox.put(id, medicine);

      // Schedule Notifications
      // Ensure NotificationService is initialized (it should be in main, but safe to call init again? 
      // No, init re-calls initialize which might be heavy. 
      // Instead, we trust main.dart. If LateInitializationError occurs, it means 
      // notificationService was not provided correctly or internal fields are null.
      // Based on previous analysis, `flutterLocalNotificationsPlugin` is final and initialized inline.
      // The error might be `tz.local` if `tz.initializeTimeZones()` wasn't called.
      // We will wrap in try-catch to not crash the UI flow if notifications fail.
      
      try {
        final notificationId = NotificationUtil.generateId(id);
        final initialSchedule = isInterval ? startTime : fixedTime!;
        
        // Calculate end date
        final DateTime endDate = initialSchedule.add(Duration(days: effectiveDuration));

        DateTime nextTime = initialSchedule;
        
        // Loop to schedule notifications
        // Limit to 50 notifications per medicine to avoid hitting OS limits (Android has limits per app)
        int count = 0;
        
        while (nextTime.isBefore(endDate) && count < 50) {
           // Skip past times
           if (nextTime.isAfter(DateTime.now())) {
              await notificationService.scheduleNotification(
                id: notificationId + count,
                title: '$profileName: time for your medicine',
                body: '$name -> take $dosage',
                scheduledDate: nextTime,
              );
              count++;
           }

           if (isInterval && intervalHours != null) {
              nextTime = nextTime.add(Duration(hours: intervalHours));
           } else {
              // Fixed time means "daily at this time"
              nextTime = nextTime.add(const Duration(days: 1));
           }
        }
      } catch (e) {
        // Log error but allow medicine to be saved
        print('Error scheduling notification: $e');
      }

      emit(AddMedicineSuccess());
    } catch (e) {
      emit(AddMedicineError(e.toString()));
    }
  }
}
