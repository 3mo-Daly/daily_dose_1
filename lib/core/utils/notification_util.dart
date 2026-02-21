class NotificationUtil {
  static int generateId(String medicineId) {
    int hash = 0;
    for (int i = 0; i < medicineId.length; i++) {
        hash = 31 * hash + medicineId.codeUnitAt(i);
    }
    // Mask to 31-bit positive int, ensuring it fits perfectly in Android integer notification bounds
    return hash & 0x7FFFFFFF;
  }
}
