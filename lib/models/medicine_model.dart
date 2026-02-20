import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 1)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String dosage;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final bool isInterval;

  @HiveField(6)
  final DateTime startTime;

  @HiveField(7)
  final int? intervalHours;

  @HiveField(8)
  final DateTime? fixedTime;

  @HiveField(10)
  final int? durationDays;

  @HiveField(9)
  final List<DateTime> history;

  // Instances that have been explicitly deleted by the user
  @HiveField(11)
  final List<DateTime> deletedOccurrences;

  // Transient property for UI state (not persisted)
  final bool isTaken;

  Medicine({
    required this.id,
    required this.profileId,
    required this.name,
    required this.dosage,
    this.imagePath,
    required this.isInterval,
    required this.startTime,
    this.intervalHours,
    this.fixedTime,
    this.durationDays,
    List<DateTime>? history,
    List<DateTime>? deletedOccurrences,
    this.isTaken = false,
  })  : history = history ?? [],
        deletedOccurrences = deletedOccurrences ?? [];

  Medicine copyWith({
    String? id,
    String? profileId,
    String? name,
    String? dosage,
    String? imagePath,
    bool? isInterval,
    DateTime? startTime,
    int? intervalHours,
    DateTime? fixedTime,
    int? durationDays,
    List<DateTime>? history,
    List<DateTime>? deletedOccurrences,
    bool? isTaken,
  }) {
    return Medicine(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      imagePath: imagePath ?? this.imagePath,
      isInterval: isInterval ?? this.isInterval,
      startTime: startTime ?? this.startTime,
      intervalHours: intervalHours ?? this.intervalHours,
      fixedTime: fixedTime ?? this.fixedTime,
      durationDays: durationDays ?? this.durationDays,
      history: history ?? this.history,
      deletedOccurrences: deletedOccurrences ?? this.deletedOccurrences,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
