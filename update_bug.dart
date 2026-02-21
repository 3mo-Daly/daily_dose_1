import 'dart:io';

void main() {
  // Update add_medicine_cubit.dart
  final addFile = File('c:\\Users\\Daly\\.gemini\\antigravity\\scratch\\daily_dose\\lib\\features\\add_medicine\\cubit\\add_medicine_cubit.dart');
  var addContent = addFile.readAsStringSync().replaceAll('\r\n', '\n');
  
  if (!addContent.contains('notification_util.dart')) {
    addContent = addContent.replaceFirst(
      "import 'add_medicine_state.dart';",
      "import '../../../core/utils/notification_util.dart';\nimport 'add_medicine_state.dart';"
    );
  }
  
  addContent = addContent.replaceAll(
    "final notificationId = id.hashCode;",
    "final notificationId = NotificationUtil.generateId(id);"
  );
  
  addContent = addContent.replaceFirst(
    "title: '\$profileName: Time for your medicine: \$name',\n                body: 'Take \$dosage',",
    "title: '\$profileName: time for your medicine',\n                body: '\$name -> take \$dosage',"
  );
  
  addFile.writeAsStringSync(addContent);

  // Update home_cubit.dart
  final homeFile = File('c:\\Users\\Daly\\.gemini\\antigravity\\scratch\\daily_dose\\lib\\features\\home\\cubit\\home_cubit.dart');
  var homeContent = homeFile.readAsStringSync().replaceAll('\r\n', '\n');
  
  if (!homeContent.contains('notification_util.dart')) {
    homeContent = homeContent.replaceFirst(
      "import 'home_state.dart';",
      "import '../../../core/utils/notification_util.dart';\nimport 'home_state.dart';"
    );
  }

  homeContent = homeContent.replaceAll(
    "final notificationId = id.hashCode;",
    "final notificationId = NotificationUtil.generateId(id);"
  );
  homeContent = homeContent.replaceAll(
    "final notificationId = medId.hashCode;",
    "final notificationId = NotificationUtil.generateId(medId);"
  );
  homeContent = homeContent.replaceAll(
    "final notificationId = medicine.id.hashCode;",
    "final notificationId = NotificationUtil.generateId(medicine.id);"
  );

  // Replace deleteMedicines implementation completely
  final startStr = "  Future<void> deleteMedicines(List<String> rawKeysOrIds) async {";
  final endStr = "    // Refresh\n    if (state is HomeLoaded) {";
  
  if (homeContent.contains(startStr) && homeContent.contains(endStr)) {
    final before = homeContent.substring(0, homeContent.indexOf(startStr));
    final after = homeContent.substring(homeContent.indexOf(endStr));
    
    final newFunc = '''  Future<void> deleteMedicines(List<String> rawKeysOrIds) async {
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

''';
    homeContent = before + newFunc + after;
  }
  
  homeFile.writeAsStringSync(homeContent);
}
