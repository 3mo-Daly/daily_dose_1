import 'dart:io';

void main() {
  final file = File('c:\\Users\\Daly\\.gemini\\antigravity\\scratch\\daily_dose\\lib\\features\\home\\cubit\\home_cubit.dart');
  var content = file.readAsStringSync();
  
  // Normalizing line endings for easy replace
  content = content.replaceAll('\r\n', '\n');
  
  content = content.replaceAll(
    "import '../../../models/medicine_model.dart';\nimport 'home_state.dart';",
    "import '../../../models/medicine_model.dart';\nimport '../../../core/services/notification_service.dart';\nimport 'home_state.dart';"
  );
  
  content = content.replaceAll(
    "  Future<void> deleteMedicine(String id) async {\n     await medicineBox.delete(id);\n     // Refresh",
    "  Future<void> deleteMedicine(String id) async {\n     await medicineBox.delete(id);\n     \n     final notificationId = id.hashCode;\n     final notificationService = NotificationService();\n     for (int i = 0; i < 50; i++) {\n        notificationService.cancelNotification(notificationId + i);\n     }\n     // Refresh"
  );

  content = content.replaceAll(
    "        } else {\n           // It's a full deletion \n           await realMedicine.delete();\n        }",
    "        } else {\n           // It's a full deletion \n           await realMedicine.delete();\n           final notificationId = medId.hashCode;\n           final notificationService = NotificationService();\n           for (int i = 0; i < 50; i++) {\n              notificationService.cancelNotification(notificationId + i);\n           }\n        }"
  );

  content = content.replaceAll(
    "  Future<void> deleteAllMedicines(String profileId) async {\n     final keysToDelete = medicineBox.values\n        .where((m) => m.profileId == profileId)\n        .map((m) => m.key)\n        .toList();\n     \n     await medicineBox.deleteAll(keysToDelete);",
    "  Future<void> deleteAllMedicines(String profileId) async {\n     final medicinesToDelete = medicineBox.values\n        .where((m) => m.profileId == profileId)\n        .toList();\n     final keysToDelete = medicinesToDelete\n        .map((m) => m.key)\n        .toList();\n     final notificationService = NotificationService();\n     for (final medicine in medicinesToDelete) {\n         final notificationId = medicine.id.hashCode;\n         for (int i = 0; i < 50; i++) {\n             notificationService.cancelNotification(notificationId + i);\n         }\n     }\n     await medicineBox.deleteAll(keysToDelete);"
  );

  file.writeAsStringSync(content);
}
