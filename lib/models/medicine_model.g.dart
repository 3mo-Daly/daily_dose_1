// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 1;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      id: fields[0] as String,
      profileId: fields[1] as String,
      name: fields[2] as String,
      dosage: fields[3] as String,
      imagePath: fields[4] as String?,
      isInterval: fields[5] as bool,
      startTime: fields[6] as DateTime,
      intervalHours: fields[7] as int?,
      fixedTime: fields[8] as DateTime?,
      durationDays: fields[10] as int?,
      history: (fields[9] as List?)?.cast<DateTime>(),
      deletedOccurrences: (fields[11] as List?)?.cast<DateTime>(),
      hideBefore: fields[12] as DateTime?,
      hideAfter: fields[13] as DateTime?,
      exactTakenTimes: (fields[14] as Map?)?.cast<String, DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.isInterval)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.intervalHours)
      ..writeByte(8)
      ..write(obj.fixedTime)
      ..writeByte(10)
      ..write(obj.durationDays)
      ..writeByte(9)
      ..write(obj.history)
      ..writeByte(11)
      ..write(obj.deletedOccurrences)
      ..writeByte(12)
      ..write(obj.hideBefore)
      ..writeByte(13)
      ..write(obj.hideAfter)
      ..writeByte(14)
      ..write(obj.exactTakenTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
